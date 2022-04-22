CREATE TABLE [Purchasing].[ProductVendor]
(
[ProductID] [int] NOT NULL,
[BusinessEntityID] [int] NOT NULL,
[AverageLeadTime] [int] NOT NULL,
[StandardPrice] [money] NOT NULL,
[LastReceiptCost] [money] NULL,
[LastReceiptDate] [datetime] NULL,
[MinOrderQty] [int] NOT NULL,
[MaxOrderQty] [int] NOT NULL,
[OnOrderQty] [int] NULL,
[UnitMeasureCode] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductVendor_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Purchasing].[ProductVendor] ADD CONSTRAINT [CK_ProductVendor_AverageLeadTime] CHECK (([AverageLeadTime]>=(1)))
GO
ALTER TABLE [Purchasing].[ProductVendor] ADD CONSTRAINT [CK_ProductVendor_LastReceiptCost] CHECK (([LastReceiptCost]>(0.00)))
GO
ALTER TABLE [Purchasing].[ProductVendor] ADD CONSTRAINT [CK_ProductVendor_MaxOrderQty] CHECK (([MaxOrderQty]>=(1)))
GO
ALTER TABLE [Purchasing].[ProductVendor] ADD CONSTRAINT [CK_ProductVendor_MinOrderQty] CHECK (([MinOrderQty]>=(1)))
GO
ALTER TABLE [Purchasing].[ProductVendor] ADD CONSTRAINT [CK_ProductVendor_OnOrderQty] CHECK (([OnOrderQty]>=(0)))
GO
ALTER TABLE [Purchasing].[ProductVendor] ADD CONSTRAINT [CK_ProductVendor_StandardPrice] CHECK (([StandardPrice]>(0.00)))
GO
ALTER TABLE [Purchasing].[ProductVendor] ADD CONSTRAINT [PK_ProductVendor_ProductID_BusinessEntityID] PRIMARY KEY CLUSTERED ([ProductID], [BusinessEntityID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProductVendor_BusinessEntityID] ON [Purchasing].[ProductVendor] ([BusinessEntityID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProductVendor_UnitMeasureCode] ON [Purchasing].[ProductVendor] ([UnitMeasureCode]) ON [PRIMARY]
GO
ALTER TABLE [Purchasing].[ProductVendor] ADD CONSTRAINT [FK_ProductVendor_Product_ProductID] FOREIGN KEY ([ProductID]) REFERENCES [Production].[Product] ([ProductID])
GO
ALTER TABLE [Purchasing].[ProductVendor] ADD CONSTRAINT [FK_ProductVendor_UnitMeasure_UnitMeasureCode] FOREIGN KEY ([UnitMeasureCode]) REFERENCES [Production].[UnitMeasure] ([UnitMeasureCode])
GO
ALTER TABLE [Purchasing].[ProductVendor] ADD CONSTRAINT [FK_ProductVendor_Vendor_BusinessEntityID] FOREIGN KEY ([BusinessEntityID]) REFERENCES [Purchasing].[Vendor] ([BusinessEntityID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cross-reference table mapping vendors with the products they supply.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The average span of time (in days) between placing an order with the vendor and receiving the purchased product.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'COLUMN', N'AverageLeadTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key. Foreign key to Vendor.BusinessEntityID.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'COLUMN', N'BusinessEntityID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The selling price when last purchased.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'COLUMN', N'LastReceiptCost'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date the product was last received by the vendor.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'COLUMN', N'LastReceiptDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The minimum quantity that should be ordered.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'COLUMN', N'MaxOrderQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The maximum quantity that should be ordered.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'COLUMN', N'MinOrderQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The quantity currently on order.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'COLUMN', N'OnOrderQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key. Foreign key to Product.ProductID.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'COLUMN', N'ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The vendor''s usual selling price.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'COLUMN', N'StandardPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The product''s unit of measure.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'COLUMN', N'UnitMeasureCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [AverageLeadTime] >= (1)', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'CONSTRAINT', N'CK_ProductVendor_AverageLeadTime'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [LastReceiptCost] > (0.00)', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'CONSTRAINT', N'CK_ProductVendor_LastReceiptCost'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [MaxOrderQty] >= (1)', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'CONSTRAINT', N'CK_ProductVendor_MaxOrderQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [MinOrderQty] >= (1)', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'CONSTRAINT', N'CK_ProductVendor_MinOrderQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [OnOrderQty] >= (0)', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'CONSTRAINT', N'CK_ProductVendor_OnOrderQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [StandardPrice] > (0.00)', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'CONSTRAINT', N'CK_ProductVendor_StandardPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'CONSTRAINT', N'DF_ProductVendor_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'CONSTRAINT', N'FK_ProductVendor_Product_ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing UnitMeasure.UnitMeasureCode.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'CONSTRAINT', N'FK_ProductVendor_UnitMeasure_UnitMeasureCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Vendor.BusinessEntityID.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'CONSTRAINT', N'FK_ProductVendor_Vendor_BusinessEntityID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'CONSTRAINT', N'PK_ProductVendor_ProductID_BusinessEntityID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nonclustered index.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'INDEX', N'IX_ProductVendor_BusinessEntityID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nonclustered index.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'INDEX', N'IX_ProductVendor_UnitMeasureCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Purchasing', 'TABLE', N'ProductVendor', 'INDEX', N'PK_ProductVendor_ProductID_BusinessEntityID'
GO
