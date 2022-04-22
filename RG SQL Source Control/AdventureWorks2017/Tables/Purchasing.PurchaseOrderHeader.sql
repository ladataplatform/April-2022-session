CREATE TABLE [Purchasing].[PurchaseOrderHeader]
(
[PurchaseOrderID] [int] NOT NULL IDENTITY(1, 1),
[RevisionNumber] [tinyint] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_RevisionNumber] DEFAULT ((0)),
[Status] [tinyint] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_Status] DEFAULT ((1)),
[EmployeeID] [int] NOT NULL,
[VendorID] [int] NOT NULL,
[ShipMethodID] [int] NOT NULL,
[OrderDate] [datetime] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_OrderDate] DEFAULT (getdate()),
[ShipDate] [datetime] NULL,
[SubTotal] [money] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_SubTotal] DEFAULT ((0.00)),
[TaxAmt] [money] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_TaxAmt] DEFAULT ((0.00)),
[Freight] [money] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_Freight] DEFAULT ((0.00)),
[TotalDue] AS (isnull(([SubTotal]+[TaxAmt])+[Freight],(0))) PERSISTED NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [Purchasing].[uPurchaseOrderHeader] ON [Purchasing].[PurchaseOrderHeader] 
AFTER UPDATE AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN TRY
        -- Update RevisionNumber for modification of any field EXCEPT the Status.
        IF NOT UPDATE([Status])
        BEGIN
            UPDATE [Purchasing].[PurchaseOrderHeader]
            SET [Purchasing].[PurchaseOrderHeader].[RevisionNumber] = 
                [Purchasing].[PurchaseOrderHeader].[RevisionNumber] + 1
            WHERE [Purchasing].[PurchaseOrderHeader].[PurchaseOrderID] IN 
                (SELECT inserted.[PurchaseOrderID] FROM inserted);
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
ALTER TABLE [Purchasing].[PurchaseOrderHeader] ADD CONSTRAINT [CK_PurchaseOrderHeader_Freight] CHECK (([Freight]>=(0.00)))
GO
ALTER TABLE [Purchasing].[PurchaseOrderHeader] ADD CONSTRAINT [CK_PurchaseOrderHeader_ShipDate] CHECK (([ShipDate]>=[OrderDate] OR [ShipDate] IS NULL))
GO
ALTER TABLE [Purchasing].[PurchaseOrderHeader] ADD CONSTRAINT [CK_PurchaseOrderHeader_Status] CHECK (([Status]>=(1) AND [Status]<=(4)))
GO
ALTER TABLE [Purchasing].[PurchaseOrderHeader] ADD CONSTRAINT [CK_PurchaseOrderHeader_SubTotal] CHECK (([SubTotal]>=(0.00)))
GO
ALTER TABLE [Purchasing].[PurchaseOrderHeader] ADD CONSTRAINT [CK_PurchaseOrderHeader_TaxAmt] CHECK (([TaxAmt]>=(0.00)))
GO
ALTER TABLE [Purchasing].[PurchaseOrderHeader] ADD CONSTRAINT [PK_PurchaseOrderHeader_PurchaseOrderID] PRIMARY KEY CLUSTERED ([PurchaseOrderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PurchaseOrderHeader_EmployeeID] ON [Purchasing].[PurchaseOrderHeader] ([EmployeeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PurchaseOrderHeader_VendorID] ON [Purchasing].[PurchaseOrderHeader] ([VendorID]) ON [PRIMARY]
GO
ALTER TABLE [Purchasing].[PurchaseOrderHeader] ADD CONSTRAINT [FK_PurchaseOrderHeader_Employee_EmployeeID] FOREIGN KEY ([EmployeeID]) REFERENCES [HumanResources].[Employee] ([BusinessEntityID])
GO
ALTER TABLE [Purchasing].[PurchaseOrderHeader] ADD CONSTRAINT [FK_PurchaseOrderHeader_ShipMethod_ShipMethodID] FOREIGN KEY ([ShipMethodID]) REFERENCES [Purchasing].[ShipMethod] ([ShipMethodID])
GO
ALTER TABLE [Purchasing].[PurchaseOrderHeader] ADD CONSTRAINT [FK_PurchaseOrderHeader_Vendor_VendorID] FOREIGN KEY ([VendorID]) REFERENCES [Purchasing].[Vendor] ([BusinessEntityID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'General purchase order information. See PurchaseOrderDetail.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Employee who created the purchase order. Foreign key to Employee.BusinessEntityID.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'COLUMN', N'EmployeeID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Shipping cost.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'COLUMN', N'Freight'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Purchase order creation date.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'COLUMN', N'OrderDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'COLUMN', N'PurchaseOrderID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Incremental number to track changes to the purchase order over time.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'COLUMN', N'RevisionNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Estimated shipment date from the vendor.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'COLUMN', N'ShipDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Shipping method. Foreign key to ShipMethod.ShipMethodID.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'COLUMN', N'ShipMethodID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Order current status. 1 = Pending; 2 = Approved; 3 = Rejected; 4 = Complete', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Purchase order subtotal. Computed as SUM(PurchaseOrderDetail.LineTotal)for the appropriate PurchaseOrderID.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'COLUMN', N'SubTotal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tax amount.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'COLUMN', N'TaxAmt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Total due to vendor. Computed as Subtotal + TaxAmt + Freight.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'COLUMN', N'TotalDue'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Vendor with whom the purchase order is placed. Foreign key to Vendor.BusinessEntityID.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'COLUMN', N'VendorID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [Freight] >= (0.00)', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'CONSTRAINT', N'CK_PurchaseOrderHeader_Freight'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [ShipDate] >= [OrderDate] OR [ShipDate] IS NULL', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'CONSTRAINT', N'CK_PurchaseOrderHeader_ShipDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [Status] BETWEEN (1) AND (4)', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'CONSTRAINT', N'CK_PurchaseOrderHeader_Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [SubTotal] >= (0.00)', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'CONSTRAINT', N'CK_PurchaseOrderHeader_SubTotal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [TaxAmt] >= (0.00)', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'CONSTRAINT', N'CK_PurchaseOrderHeader_TaxAmt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'CONSTRAINT', N'DF_PurchaseOrderHeader_Freight'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'CONSTRAINT', N'DF_PurchaseOrderHeader_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'CONSTRAINT', N'DF_PurchaseOrderHeader_OrderDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'CONSTRAINT', N'DF_PurchaseOrderHeader_RevisionNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 1', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'CONSTRAINT', N'DF_PurchaseOrderHeader_Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'CONSTRAINT', N'DF_PurchaseOrderHeader_SubTotal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'CONSTRAINT', N'DF_PurchaseOrderHeader_TaxAmt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Employee.EmployeeID.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'CONSTRAINT', N'FK_PurchaseOrderHeader_Employee_EmployeeID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing ShipMethod.ShipMethodID.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'CONSTRAINT', N'FK_PurchaseOrderHeader_ShipMethod_ShipMethodID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Vendor.VendorID.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'CONSTRAINT', N'FK_PurchaseOrderHeader_Vendor_VendorID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'CONSTRAINT', N'PK_PurchaseOrderHeader_PurchaseOrderID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nonclustered index.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'INDEX', N'IX_PurchaseOrderHeader_EmployeeID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nonclustered index.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'INDEX', N'IX_PurchaseOrderHeader_VendorID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'INDEX', N'PK_PurchaseOrderHeader_PurchaseOrderID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'AFTER UPDATE trigger that updates the RevisionNumber and ModifiedDate columns in the PurchaseOrderHeader table.', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderHeader', 'TRIGGER', N'uPurchaseOrderHeader'
GO
