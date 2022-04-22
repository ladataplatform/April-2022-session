CREATE TABLE [Production].[ProductProductPhoto]
(
[ProductID] [int] NOT NULL,
[ProductPhotoID] [int] NOT NULL,
[Primary] [dbo].[Flag] NOT NULL CONSTRAINT [DF_ProductProductPhoto_Primary] DEFAULT ((0)),
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductProductPhoto_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Production].[ProductProductPhoto] ADD CONSTRAINT [PK_ProductProductPhoto_ProductID_ProductPhotoID] PRIMARY KEY NONCLUSTERED ([ProductID], [ProductPhotoID]) ON [PRIMARY]
GO
ALTER TABLE [Production].[ProductProductPhoto] ADD CONSTRAINT [FK_ProductProductPhoto_Product_ProductID] FOREIGN KEY ([ProductID]) REFERENCES [Production].[Product] ([ProductID])
GO
ALTER TABLE [Production].[ProductProductPhoto] ADD CONSTRAINT [FK_ProductProductPhoto_ProductPhoto_ProductPhotoID] FOREIGN KEY ([ProductPhotoID]) REFERENCES [Production].[ProductPhoto] ([ProductPhotoID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cross-reference table mapping products and product photos.', 'SCHEMA', N'Production', 'TABLE', N'ProductProductPhoto', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Production', 'TABLE', N'ProductProductPhoto', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'0 = Photo is not the principal image. 1 = Photo is the principal image.', 'SCHEMA', N'Production', 'TABLE', N'ProductProductPhoto', 'COLUMN', N'Primary'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product identification number. Foreign key to Product.ProductID.', 'SCHEMA', N'Production', 'TABLE', N'ProductProductPhoto', 'COLUMN', N'ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product photo identification number. Foreign key to ProductPhoto.ProductPhotoID.', 'SCHEMA', N'Production', 'TABLE', N'ProductProductPhoto', 'COLUMN', N'ProductPhotoID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Production', 'TABLE', N'ProductProductPhoto', 'CONSTRAINT', N'DF_ProductProductPhoto_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0 (FALSE)', 'SCHEMA', N'Production', 'TABLE', N'ProductProductPhoto', 'CONSTRAINT', N'DF_ProductProductPhoto_Primary'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', 'SCHEMA', N'Production', 'TABLE', N'ProductProductPhoto', 'CONSTRAINT', N'FK_ProductProductPhoto_Product_ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing ProductPhoto.ProductPhotoID.', 'SCHEMA', N'Production', 'TABLE', N'ProductProductPhoto', 'CONSTRAINT', N'FK_ProductProductPhoto_ProductPhoto_ProductPhotoID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Production', 'TABLE', N'ProductProductPhoto', 'CONSTRAINT', N'PK_ProductProductPhoto_ProductID_ProductPhotoID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nonclustered index created by a primary key constraint.', 'SCHEMA', N'Production', 'TABLE', N'ProductProductPhoto', 'INDEX', N'PK_ProductProductPhoto_ProductID_ProductPhotoID'
GO
