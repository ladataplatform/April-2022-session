CREATE TABLE [Production].[ProductSubcategory]
(
[ProductSubcategoryID] [int] NOT NULL IDENTITY(1, 1),
[ProductCategoryID] [int] NOT NULL,
[Name] [dbo].[Name] NOT NULL,
[rowguid] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_ProductSubcategory_rowguid] DEFAULT (newid()),
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductSubcategory_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Production].[ProductSubcategory] ADD CONSTRAINT [PK_ProductSubcategory_ProductSubcategoryID] PRIMARY KEY CLUSTERED ([ProductSubcategoryID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_ProductSubcategory_Name] ON [Production].[ProductSubcategory] ([Name]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_ProductSubcategory_rowguid] ON [Production].[ProductSubcategory] ([rowguid]) ON [PRIMARY]
GO
ALTER TABLE [Production].[ProductSubcategory] ADD CONSTRAINT [FK_ProductSubcategory_ProductCategory_ProductCategoryID] FOREIGN KEY ([ProductCategoryID]) REFERENCES [Production].[ProductCategory] ([ProductCategoryID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product subcategories. See ProductCategory table.', 'SCHEMA', N'Production', 'TABLE', N'ProductSubcategory', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Production', 'TABLE', N'ProductSubcategory', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Subcategory description.', 'SCHEMA', N'Production', 'TABLE', N'ProductSubcategory', 'COLUMN', N'Name'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product category identification number. Foreign key to ProductCategory.ProductCategoryID.', 'SCHEMA', N'Production', 'TABLE', N'ProductSubcategory', 'COLUMN', N'ProductCategoryID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key for ProductSubcategory records.', 'SCHEMA', N'Production', 'TABLE', N'ProductSubcategory', 'COLUMN', N'ProductSubcategoryID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', 'SCHEMA', N'Production', 'TABLE', N'ProductSubcategory', 'COLUMN', N'rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Production', 'TABLE', N'ProductSubcategory', 'CONSTRAINT', N'DF_ProductSubcategory_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of NEWID()', 'SCHEMA', N'Production', 'TABLE', N'ProductSubcategory', 'CONSTRAINT', N'DF_ProductSubcategory_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing ProductCategory.ProductCategoryID.', 'SCHEMA', N'Production', 'TABLE', N'ProductSubcategory', 'CONSTRAINT', N'FK_ProductSubcategory_ProductCategory_ProductCategoryID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Production', 'TABLE', N'ProductSubcategory', 'CONSTRAINT', N'PK_ProductSubcategory_ProductSubcategoryID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index.', 'SCHEMA', N'Production', 'TABLE', N'ProductSubcategory', 'INDEX', N'AK_ProductSubcategory_Name'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', 'SCHEMA', N'Production', 'TABLE', N'ProductSubcategory', 'INDEX', N'AK_ProductSubcategory_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Production', 'TABLE', N'ProductSubcategory', 'INDEX', N'PK_ProductSubcategory_ProductSubcategoryID'
GO
