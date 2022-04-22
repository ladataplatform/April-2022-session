CREATE TABLE [Production].[Product]
(
[ProductID] [int] NOT NULL IDENTITY(1, 1),
[Name] [dbo].[Name] NOT NULL,
[ProductNumber] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MakeFlag] [dbo].[Flag] NOT NULL CONSTRAINT [DF_Product_MakeFlag] DEFAULT ((1)),
[FinishedGoodsFlag] [dbo].[Flag] NOT NULL CONSTRAINT [DF_Product_FinishedGoodsFlag] DEFAULT ((1)),
[Color] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SafetyStockLevel] [smallint] NOT NULL,
[ReorderPoint] [smallint] NOT NULL,
[StandardCost] [money] NOT NULL,
[ListPrice] [money] NOT NULL,
[Size] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SizeUnitMeasureCode] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WeightUnitMeasureCode] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [decimal] (8, 2) NULL,
[DaysToManufacture] [int] NOT NULL,
[ProductLine] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Class] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Style] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductSubcategoryID] [int] NULL,
[ProductModelID] [int] NULL,
[SellStartDate] [datetime] NOT NULL,
[SellEndDate] [datetime] NULL,
[DiscontinuedDate] [datetime] NULL,
[rowguid] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_Product_rowguid] DEFAULT (newid()),
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Product_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [CK_Product_Class] CHECK ((upper([Class])='H' OR upper([Class])='M' OR upper([Class])='L' OR [Class] IS NULL))
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [CK_Product_DaysToManufacture] CHECK (([DaysToManufacture]>=(0)))
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [CK_Product_ListPrice] CHECK (([ListPrice]>=(0.00)))
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [CK_Product_ProductLine] CHECK ((upper([ProductLine])='R' OR upper([ProductLine])='M' OR upper([ProductLine])='T' OR upper([ProductLine])='S' OR [ProductLine] IS NULL))
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [CK_Product_ReorderPoint] CHECK (([ReorderPoint]>(0)))
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [CK_Product_SafetyStockLevel] CHECK (([SafetyStockLevel]>(0)))
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [CK_Product_SellEndDate] CHECK (([SellEndDate]>=[SellStartDate] OR [SellEndDate] IS NULL))
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [CK_Product_StandardCost] CHECK (([StandardCost]>=(0.00)))
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [CK_Product_Style] CHECK ((upper([Style])='U' OR upper([Style])='M' OR upper([Style])='W' OR [Style] IS NULL))
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [CK_Product_Weight] CHECK (([Weight]>(0.00)))
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [PK_Product_ProductID] PRIMARY KEY CLUSTERED ([ProductID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_Product_Name] ON [Production].[Product] ([Name]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_Product_ProductNumber] ON [Production].[Product] ([ProductNumber]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_Product_rowguid] ON [Production].[Product] ([rowguid]) ON [PRIMARY]
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [FK_Product_ProductModel_ProductModelID] FOREIGN KEY ([ProductModelID]) REFERENCES [Production].[ProductModel] ([ProductModelID])
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [FK_Product_ProductSubcategory_ProductSubcategoryID] FOREIGN KEY ([ProductSubcategoryID]) REFERENCES [Production].[ProductSubcategory] ([ProductSubcategoryID])
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [FK_Product_UnitMeasure_SizeUnitMeasureCode] FOREIGN KEY ([SizeUnitMeasureCode]) REFERENCES [Production].[UnitMeasure] ([UnitMeasureCode])
GO
ALTER TABLE [Production].[Product] ADD CONSTRAINT [FK_Product_UnitMeasure_WeightUnitMeasureCode] FOREIGN KEY ([WeightUnitMeasureCode]) REFERENCES [Production].[UnitMeasure] ([UnitMeasureCode])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Products sold or used in the manfacturing of sold products.', 'SCHEMA', N'Production', 'TABLE', N'Product', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'H = High, M = Medium, L = Low', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'Class'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product color.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'Color'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Number of days required to manufacture the product.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'DaysToManufacture'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date the product was discontinued.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'DiscontinuedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'0 = Product is not a salable item. 1 = Product is salable.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'FinishedGoodsFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Selling price.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'ListPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'0 = Product is purchased, 1 = Product is manufactured in-house.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'MakeFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the product.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'Name'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key for Product records.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'R = Road, M = Mountain, T = Touring, S = Standard', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'ProductLine'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product is a member of this product model. Foreign key to ProductModel.ProductModelID.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'ProductModelID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique product identification number.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'ProductNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product is a member of this product subcategory. Foreign key to ProductSubCategory.ProductSubCategoryID. ', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'ProductSubcategoryID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Inventory level that triggers a purchase order or work order. ', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'ReorderPoint'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Minimum inventory quantity. ', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'SafetyStockLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date the product was no longer available for sale.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'SellEndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date the product was available for sale.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'SellStartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product size.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'Size'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unit of measure for Size column.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'SizeUnitMeasureCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Standard cost of the product.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'StandardCost'
GO
EXEC sp_addextendedproperty N'MS_Description', N'W = Womens, M = Mens, U = Universal', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'Style'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product weight.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'Weight'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unit of measure for Weight column.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'COLUMN', N'WeightUnitMeasureCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [Class]=''h'' OR [Class]=''m'' OR [Class]=''l'' OR [Class]=''H'' OR [Class]=''M'' OR [Class]=''L'' OR [Class] IS NULL', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'CK_Product_Class'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [DaysToManufacture] >= (0)', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'CK_Product_DaysToManufacture'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [ListPrice] >= (0.00)', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'CK_Product_ListPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [ProductLine]=''r'' OR [ProductLine]=''m'' OR [ProductLine]=''t'' OR [ProductLine]=''s'' OR [ProductLine]=''R'' OR [ProductLine]=''M'' OR [ProductLine]=''T'' OR [ProductLine]=''S'' OR [ProductLine] IS NULL', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'CK_Product_ProductLine'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [ReorderPoint] > (0)', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'CK_Product_ReorderPoint'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [SafetyStockLevel] > (0)', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'CK_Product_SafetyStockLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [SellEndDate] >= [SellStartDate] OR [SellEndDate] IS NULL', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'CK_Product_SellEndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [SafetyStockLevel] > (0)', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'CK_Product_StandardCost'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [Style]=''u'' OR [Style]=''m'' OR [Style]=''w'' OR [Style]=''U'' OR [Style]=''M'' OR [Style]=''W'' OR [Style] IS NULL', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'CK_Product_Style'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [Weight] > (0.00)', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'CK_Product_Weight'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of  1', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'DF_Product_FinishedGoodsFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of  1', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'DF_Product_MakeFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'DF_Product_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of NEWID()', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'DF_Product_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing ProductModel.ProductModelID.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'FK_Product_ProductModel_ProductModelID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing ProductSubcategory.ProductSubcategoryID.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'FK_Product_ProductSubcategory_ProductSubcategoryID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing UnitMeasure.UnitMeasureCode.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'FK_Product_UnitMeasure_SizeUnitMeasureCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing UnitMeasure.UnitMeasureCode.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'FK_Product_UnitMeasure_WeightUnitMeasureCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Production', 'TABLE', N'Product', 'CONSTRAINT', N'PK_Product_ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'INDEX', N'AK_Product_Name'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'INDEX', N'AK_Product_ProductNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'INDEX', N'AK_Product_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Production', 'TABLE', N'Product', 'INDEX', N'PK_Product_ProductID'
GO
