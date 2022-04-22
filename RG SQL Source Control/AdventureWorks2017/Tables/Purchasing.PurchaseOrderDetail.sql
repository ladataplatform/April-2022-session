CREATE TABLE [Purchasing].[PurchaseOrderDetail]
(
[PurchaseOrderID] [int] NOT NULL,
[PurchaseOrderDetailID] [int] NOT NULL IDENTITY(1, 1),
[DueDate] [datetime] NOT NULL,
[OrderQty] [smallint] NOT NULL,
[ProductID] [int] NOT NULL,
[UnitPrice] [money] NOT NULL,
[LineTotal] AS (isnull([OrderQty]*[UnitPrice],(0.00))),
[ReceivedQty] [decimal] (8, 2) NOT NULL,
[RejectedQty] [decimal] (8, 2) NOT NULL,
[StockedQty] AS (isnull([ReceivedQty]-[RejectedQty],(0.00))),
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_PurchaseOrderDetail_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [Purchasing].[iPurchaseOrderDetail] ON [Purchasing].[PurchaseOrderDetail] 
AFTER INSERT AS
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO [Production].[TransactionHistory]
            ([ProductID]
            ,[ReferenceOrderID]
            ,[ReferenceOrderLineID]
            ,[TransactionType]
            ,[TransactionDate]
            ,[Quantity]
            ,[ActualCost])
        SELECT 
            inserted.[ProductID]
            ,inserted.[PurchaseOrderID]
            ,inserted.[PurchaseOrderDetailID]
            ,'P'
            ,GETDATE()
            ,inserted.[OrderQty]
            ,inserted.[UnitPrice]
        FROM inserted 
            INNER JOIN [Purchasing].[PurchaseOrderHeader] 
            ON inserted.[PurchaseOrderID] = [Purchasing].[PurchaseOrderHeader].[PurchaseOrderID];

        -- Update SubTotal in PurchaseOrderHeader record. Note that this causes the 
        -- PurchaseOrderHeader trigger to fire which will update the RevisionNumber.
        UPDATE [Purchasing].[PurchaseOrderHeader]
        SET [Purchasing].[PurchaseOrderHeader].[SubTotal] = 
            (SELECT SUM([Purchasing].[PurchaseOrderDetail].[LineTotal])
                FROM [Purchasing].[PurchaseOrderDetail]
                WHERE [Purchasing].[PurchaseOrderHeader].[PurchaseOrderID] = [Purchasing].[PurchaseOrderDetail].[PurchaseOrderID])
        WHERE [Purchasing].[PurchaseOrderHeader].[PurchaseOrderID] IN (SELECT inserted.[PurchaseOrderID] FROM inserted);
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspPrintError];

        -- Rollback any active or uncommittable transactions before
        -- inserting information in the ErrorLog
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [Purchasing].[uPurchaseOrderDetail] ON [Purchasing].[PurchaseOrderDetail] 
AFTER UPDATE AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN TRY
        IF UPDATE([ProductID]) OR UPDATE([OrderQty]) OR UPDATE([UnitPrice])
        -- Insert record into TransactionHistory 
        BEGIN
            INSERT INTO [Production].[TransactionHistory]
                ([ProductID]
                ,[ReferenceOrderID]
                ,[ReferenceOrderLineID]
                ,[TransactionType]
                ,[TransactionDate]
                ,[Quantity]
                ,[ActualCost])
            SELECT 
                inserted.[ProductID]
                ,inserted.[PurchaseOrderID]
                ,inserted.[PurchaseOrderDetailID]
                ,'P'
                ,GETDATE()
                ,inserted.[OrderQty]
                ,inserted.[UnitPrice]
            FROM inserted 
                INNER JOIN [Purchasing].[PurchaseOrderDetail] 
                ON inserted.[PurchaseOrderID] = [Purchasing].[PurchaseOrderDetail].[PurchaseOrderID];

            -- Update SubTotal in PurchaseOrderHeader record. Note that this causes the 
            -- PurchaseOrderHeader trigger to fire which will update the RevisionNumber.
            UPDATE [Purchasing].[PurchaseOrderHeader]
            SET [Purchasing].[PurchaseOrderHeader].[SubTotal] = 
                (SELECT SUM([Purchasing].[PurchaseOrderDetail].[LineTotal])
                    FROM [Purchasing].[PurchaseOrderDetail]
                    WHERE [Purchasing].[PurchaseOrderHeader].[PurchaseOrderID] 
                        = [Purchasing].[PurchaseOrderDetail].[PurchaseOrderID])
            WHERE [Purchasing].[PurchaseOrderHeader].[PurchaseOrderID] 
                IN (SELECT inserted.[PurchaseOrderID] FROM inserted);

            UPDATE [Purchasing].[PurchaseOrderDetail]
            SET [Purchasing].[PurchaseOrderDetail].[ModifiedDate] = GETDATE()
            FROM inserted
            WHERE inserted.[PurchaseOrderID] = [Purchasing].[PurchaseOrderDetail].[PurchaseOrderID]
                AND inserted.[PurchaseOrderDetailID] = [Purchasing].[PurchaseOrderDetail].[PurchaseOrderDetailID];
        END;
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspPrintError];

        -- Rollback any active or uncommittable transactions before
        -- inserting information in the ErrorLog
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO
ALTER TABLE [Purchasing].[PurchaseOrderDetail] ADD CONSTRAINT [CK_PurchaseOrderDetail_OrderQty] CHECK (([OrderQty]>(0)))
GO
ALTER TABLE [Purchasing].[PurchaseOrderDetail] ADD CONSTRAINT [CK_PurchaseOrderDetail_ReceivedQty] CHECK (([ReceivedQty]>=(0.00)))
GO
ALTER TABLE [Purchasing].[PurchaseOrderDetail] ADD CONSTRAINT [CK_PurchaseOrderDetail_RejectedQty] CHECK (([RejectedQty]>=(0.00)))
GO
ALTER TABLE [Purchasing].[PurchaseOrderDetail] ADD CONSTRAINT [CK_PurchaseOrderDetail_UnitPrice] CHECK (([UnitPrice]>=(0.00)))
GO
ALTER TABLE [Purchasing].[PurchaseOrderDetail] ADD CONSTRAINT [PK_PurchaseOrderDetail_PurchaseOrderID_PurchaseOrderDetailID] PRIMARY KEY CLUSTERED ([PurchaseOrderID], [PurchaseOrderDetailID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PurchaseOrderDetail_ProductID] ON [Purchasing].[PurchaseOrderDetail] ([ProductID]) ON [PRIMARY]
GO
ALTER TABLE [Purchasing].[PurchaseOrderDetail] ADD CONSTRAINT [FK_PurchaseOrderDetail_Product_ProductID] FOREIGN KEY ([ProductID]) REFERENCES [Production].[Product] ([ProductID])
GO
ALTER TABLE [Purchasing].[PurchaseOrderDetail] ADD CONSTRAINT [FK_PurchaseOrderDetail_PurchaseOrderHeader_PurchaseOrderID] FOREIGN KEY ([PurchaseOrderID]) REFERENCES [Purchasing].[PurchaseOrderHeader] ([PurchaseOrderID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Individual products associated with a specific purchase order. See PurchaseOrderHeader.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date the product is expected to be received.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'COLUMN', N'DueDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Per product subtotal. Computed as OrderQty * UnitPrice.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'COLUMN', N'LineTotal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity ordered.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'COLUMN', N'OrderQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product identification number. Foreign key to Product.ProductID.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'COLUMN', N'ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key. One line number per purchased product.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'COLUMN', N'PurchaseOrderDetailID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key. Foreign key to PurchaseOrderHeader.PurchaseOrderID.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'COLUMN', N'PurchaseOrderID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity actually received from the vendor.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'COLUMN', N'ReceivedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity rejected during inspection.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'COLUMN', N'RejectedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity accepted into inventory. Computed as ReceivedQty - RejectedQty.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'COLUMN', N'StockedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Vendor''s selling price of a single product.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'COLUMN', N'UnitPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [OrderQty] > (0)', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'CONSTRAINT', N'CK_PurchaseOrderDetail_OrderQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [ReceivedQty] >= (0.00)', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'CONSTRAINT', N'CK_PurchaseOrderDetail_ReceivedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [RejectedQty] >= (0.00)', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'CONSTRAINT', N'CK_PurchaseOrderDetail_RejectedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [UnitPrice] >= (0.00)', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'CONSTRAINT', N'CK_PurchaseOrderDetail_UnitPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'CONSTRAINT', N'DF_PurchaseOrderDetail_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'CONSTRAINT', N'FK_PurchaseOrderDetail_Product_ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing PurchaseOrderHeader.PurchaseOrderID.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'CONSTRAINT', N'FK_PurchaseOrderDetail_PurchaseOrderHeader_PurchaseOrderID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'CONSTRAINT', N'PK_PurchaseOrderDetail_PurchaseOrderID_PurchaseOrderDetailID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nonclustered index.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'INDEX', N'IX_PurchaseOrderDetail_ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'INDEX', N'PK_PurchaseOrderDetail_PurchaseOrderID_PurchaseOrderDetailID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'AFTER INSERT trigger that inserts a row in the TransactionHistory table and updates the PurchaseOrderHeader.SubTotal column.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'TRIGGER', N'iPurchaseOrderDetail'
GO
EXEC sp_addextendedproperty N'MS_Description', N'AFTER UPDATE trigger that inserts a row in the TransactionHistory table, updates ModifiedDate in PurchaseOrderDetail and updates the PurchaseOrderHeader.SubTotal column.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderDetail', 'TRIGGER', N'uPurchaseOrderDetail'
GO
