CREATE TABLE [Production].[ProductCostHistory]
(
[ProductID] [int] NOT NULL,
[StartDate] [datetime] NOT NULL,
[EndDate] [datetime] NULL,
[StandardCost] [money] NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductCostHistory_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Production].[ProductCostHistory] ADD CONSTRAINT [CK_ProductCostHistory_EndDate] CHECK (([EndDate]>=[StartDate] OR [EndDate] IS NULL))
GO
ALTER TABLE [Production].[ProductCostHistory] ADD CONSTRAINT [CK_ProductCostHistory_StandardCost] CHECK (([StandardCost]>=(0.00)))
GO
ALTER TABLE [Production].[ProductCostHistory] ADD CONSTRAINT [PK_ProductCostHistory_ProductID_StartDate] PRIMARY KEY CLUSTERED ([ProductID], [StartDate]) ON [PRIMARY]
GO
ALTER TABLE [Production].[ProductCostHistory] ADD CONSTRAINT [FK_ProductCostHistory_Product_ProductID] FOREIGN KEY ([ProductID]) REFERENCES [Production].[Product] ([ProductID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Changes in the cost of a product over time.', 'SCHEMA', N'Production', 'TABLE', N'ProductCostHistory', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product cost end date.', 'SCHEMA', N'Production', 'TABLE', N'ProductCostHistory', 'COLUMN', N'EndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Production', 'TABLE', N'ProductCostHistory', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product identification number. Foreign key to Product.ProductID', 'SCHEMA', N'Production', 'TABLE', N'ProductCostHistory', 'COLUMN', N'ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Standard cost of the product.', 'SCHEMA', N'Production', 'TABLE', N'ProductCostHistory', 'COLUMN', N'StandardCost'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product cost start date.', 'SCHEMA', N'Production', 'TABLE', N'ProductCostHistory', 'COLUMN', N'StartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [EndDate] >= [StartDate] OR [EndDate] IS NULL', 'SCHEMA', N'Production', 'TABLE', N'ProductCostHistory', 'CONSTRAINT', N'CK_ProductCostHistory_EndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [StandardCost] >= (0.00)', 'SCHEMA', N'Production', 'TABLE', N'ProductCostHistory', 'CONSTRAINT', N'CK_ProductCostHistory_StandardCost'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Production', 'TABLE', N'ProductCostHistory', 'CONSTRAINT', N'DF_ProductCostHistory_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', 'SCHEMA', N'Production', 'TABLE', N'ProductCostHistory', 'CONSTRAINT', N'FK_ProductCostHistory_Product_ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Production', 'TABLE', N'ProductCostHistory', 'CONSTRAINT', N'PK_ProductCostHistory_ProductID_StartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Production', 'TABLE', N'ProductCostHistory', 'INDEX', N'PK_ProductCostHistory_ProductID_StartDate'
GO
