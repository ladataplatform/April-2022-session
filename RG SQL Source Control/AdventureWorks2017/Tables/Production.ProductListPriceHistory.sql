CREATE TABLE [Production].[ProductListPriceHistory]
(
[ProductID] [int] NOT NULL,
[StartDate] [datetime] NOT NULL,
[EndDate] [datetime] NULL,
[ListPrice] [money] NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductListPriceHistory_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Production].[ProductListPriceHistory] ADD CONSTRAINT [CK_ProductListPriceHistory_EndDate] CHECK (([EndDate]>=[StartDate] OR [EndDate] IS NULL))
GO
ALTER TABLE [Production].[ProductListPriceHistory] ADD CONSTRAINT [CK_ProductListPriceHistory_ListPrice] CHECK (([ListPrice]>(0.00)))
GO
ALTER TABLE [Production].[ProductListPriceHistory] ADD CONSTRAINT [PK_ProductListPriceHistory_ProductID_StartDate] PRIMARY KEY CLUSTERED ([ProductID], [StartDate]) ON [PRIMARY]
GO
ALTER TABLE [Production].[ProductListPriceHistory] ADD CONSTRAINT [FK_ProductListPriceHistory_Product_ProductID] FOREIGN KEY ([ProductID]) REFERENCES [Production].[Product] ([ProductID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Changes in the list price of a product over time.', 'SCHEMA', N'Production', 'TABLE', N'ProductListPriceHistory', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'List price end date', 'SCHEMA', N'Production', 'TABLE', N'ProductListPriceHistory', 'COLUMN', N'EndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product list price.', 'SCHEMA', N'Production', 'TABLE', N'ProductListPriceHistory', 'COLUMN', N'ListPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Production', 'TABLE', N'ProductListPriceHistory', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product identification number. Foreign key to Product.ProductID', 'SCHEMA', N'Production', 'TABLE', N'ProductListPriceHistory', 'COLUMN', N'ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'List price start date.', 'SCHEMA', N'Production', 'TABLE', N'ProductListPriceHistory', 'COLUMN', N'StartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [EndDate] >= [StartDate] OR [EndDate] IS NULL', 'SCHEMA', N'Production', 'TABLE', N'ProductListPriceHistory', 'CONSTRAINT', N'CK_ProductListPriceHistory_EndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [ListPrice] > (0.00)', 'SCHEMA', N'Production', 'TABLE', N'ProductListPriceHistory', 'CONSTRAINT', N'CK_ProductListPriceHistory_ListPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Production', 'TABLE', N'ProductListPriceHistory', 'CONSTRAINT', N'DF_ProductListPriceHistory_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', 'SCHEMA', N'Production', 'TABLE', N'ProductListPriceHistory', 'CONSTRAINT', N'FK_ProductListPriceHistory_Product_ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Production', 'TABLE', N'ProductListPriceHistory', 'CONSTRAINT', N'PK_ProductListPriceHistory_ProductID_StartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Production', 'TABLE', N'ProductListPriceHistory', 'INDEX', N'PK_ProductListPriceHistory_ProductID_StartDate'
GO
