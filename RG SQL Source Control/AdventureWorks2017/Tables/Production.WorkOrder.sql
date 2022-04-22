CREATE TABLE [Production].[WorkOrder]
(
[WorkOrderID] [int] NOT NULL IDENTITY(1, 1),
[ProductID] [int] NOT NULL,
[OrderQty] [int] NOT NULL,
[StockedQty] AS (isnull([OrderQty]-[ScrappedQty],(0))),
[ScrappedQty] [smallint] NOT NULL,
[StartDate] [datetime] NOT NULL,
[EndDate] [datetime] NULL,
[DueDate] [datetime] NOT NULL,
[ScrapReasonID] [smallint] NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrder_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [Production].[iWorkOrder] ON [Production].[WorkOrder] 
AFTER INSERT AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO [Production].[TransactionHistory](
            [ProductID]
            ,[ReferenceOrderID]
            ,[TransactionType]
            ,[TransactionDate]
            ,[Quantity]
            ,[ActualCost])
        SELECT 
            inserted.[ProductID]
            ,inserted.[WorkOrderID]
            ,'W'
            ,GETDATE()
            ,inserted.[OrderQty]
            ,0
        FROM inserted;
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

CREATE TRIGGER [Production].[uWorkOrder] ON [Production].[WorkOrder] 
AFTER UPDATE AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN TRY
        IF UPDATE([ProductID]) OR UPDATE([OrderQty])
        BEGIN
            INSERT INTO [Production].[TransactionHistory](
                [ProductID]
                ,[ReferenceOrderID]
                ,[TransactionType]
                ,[TransactionDate]
                ,[Quantity])
            SELECT 
                inserted.[ProductID]
                ,inserted.[WorkOrderID]
                ,'W'
                ,GETDATE()
                ,inserted.[OrderQty]
            FROM inserted;
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
ALTER TABLE [Production].[WorkOrder] ADD CONSTRAINT [CK_WorkOrder_EndDate] CHECK (([EndDate]>=[StartDate] OR [EndDate] IS NULL))
GO
ALTER TABLE [Production].[WorkOrder] ADD CONSTRAINT [CK_WorkOrder_OrderQty] CHECK (([OrderQty]>(0)))
GO
ALTER TABLE [Production].[WorkOrder] ADD CONSTRAINT [CK_WorkOrder_ScrappedQty] CHECK (([ScrappedQty]>=(0)))
GO
ALTER TABLE [Production].[WorkOrder] ADD CONSTRAINT [PK_WorkOrder_WorkOrderID] PRIMARY KEY CLUSTERED ([WorkOrderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WorkOrder_ProductID] ON [Production].[WorkOrder] ([ProductID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WorkOrder_ScrapReasonID] ON [Production].[WorkOrder] ([ScrapReasonID]) ON [PRIMARY]
GO
ALTER TABLE [Production].[WorkOrder] ADD CONSTRAINT [FK_WorkOrder_Product_ProductID] FOREIGN KEY ([ProductID]) REFERENCES [Production].[Product] ([ProductID])
GO
ALTER TABLE [Production].[WorkOrder] ADD CONSTRAINT [FK_WorkOrder_ScrapReason_ScrapReasonID] FOREIGN KEY ([ScrapReasonID]) REFERENCES [Production].[ScrapReason] ([ScrapReasonID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Manufacturing work orders.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work order due date.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'COLUMN', N'DueDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work order end date.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'COLUMN', N'EndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product quantity to build.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'COLUMN', N'OrderQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product identification number. Foreign key to Product.ProductID.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'COLUMN', N'ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity that failed inspection.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'COLUMN', N'ScrappedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Reason for inspection failure.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'COLUMN', N'ScrapReasonID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work order start date.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'COLUMN', N'StartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity built and put in inventory.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'COLUMN', N'StockedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key for WorkOrder records.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'COLUMN', N'WorkOrderID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [EndDate] >= [StartDate] OR [EndDate] IS NULL', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'CONSTRAINT', N'CK_WorkOrder_EndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [OrderQty] > (0)', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'CONSTRAINT', N'CK_WorkOrder_OrderQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [ScrappedQty] >= (0)', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'CONSTRAINT', N'CK_WorkOrder_ScrappedQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'CONSTRAINT', N'DF_WorkOrder_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'CONSTRAINT', N'FK_WorkOrder_Product_ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing ScrapReason.ScrapReasonID.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'CONSTRAINT', N'FK_WorkOrder_ScrapReason_ScrapReasonID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'CONSTRAINT', N'PK_WorkOrder_WorkOrderID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nonclustered index.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'INDEX', N'IX_WorkOrder_ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nonclustered index.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'INDEX', N'IX_WorkOrder_ScrapReasonID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'INDEX', N'PK_WorkOrder_WorkOrderID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'AFTER INSERT trigger that inserts a row in the TransactionHistory table.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'TRIGGER', N'iWorkOrder'
GO
EXEC sp_addextendedproperty N'MS_Description', N'AFTER UPDATE trigger that inserts a row in the TransactionHistory table, updates ModifiedDate in the WorkOrder table.', 'SCHEMA', N'Production', 'TABLE', N'WorkOrder', 'TRIGGER', N'uWorkOrder'
GO
