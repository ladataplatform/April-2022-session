CREATE TABLE [Production].[ProductInventory]
(
[ProductID] [int] NOT NULL,
[LocationID] [smallint] NOT NULL,
[Shelf] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Bin] [tinyint] NOT NULL,
[Quantity] [smallint] NOT NULL CONSTRAINT [DF_ProductInventory_Quantity] DEFAULT ((0)),
[rowguid] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_ProductInventory_rowguid] DEFAULT (newid()),
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductInventory_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Production].[ProductInventory] ADD CONSTRAINT [CK_ProductInventory_Bin] CHECK (([Bin]>=(0) AND [Bin]<=(100)))
GO
ALTER TABLE [Production].[ProductInventory] ADD CONSTRAINT [CK_ProductInventory_Shelf] CHECK (([Shelf] like '[A-Za-z]' OR [Shelf]='N/A'))
GO
ALTER TABLE [Production].[ProductInventory] ADD CONSTRAINT [PK_ProductInventory_ProductID_LocationID] PRIMARY KEY CLUSTERED ([ProductID], [LocationID]) ON [PRIMARY]
GO
ALTER TABLE [Production].[ProductInventory] ADD CONSTRAINT [FK_ProductInventory_Location_LocationID] FOREIGN KEY ([LocationID]) REFERENCES [Production].[Location] ([LocationID])
GO
ALTER TABLE [Production].[ProductInventory] ADD CONSTRAINT [FK_ProductInventory_Product_ProductID] FOREIGN KEY ([ProductID]) REFERENCES [Production].[Product] ([ProductID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product inventory information.', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storage container on a shelf in an inventory location.', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', 'COLUMN', N'Bin'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Inventory location identification number. Foreign key to Location.LocationID. ', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', 'COLUMN', N'LocationID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product identification number. Foreign key to Product.ProductID.', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', 'COLUMN', N'ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Quantity of products in the inventory location.', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', 'COLUMN', N'Quantity'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', 'COLUMN', N'rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storage compartment within an inventory location.', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', 'COLUMN', N'Shelf'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [Bin] BETWEEN (0) AND (100)', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', 'CONSTRAINT', N'CK_ProductInventory_Bin'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [Shelf] like ''[A-Za-z]'' OR [Shelf]=''N/A''', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', 'CONSTRAINT', N'CK_ProductInventory_Shelf'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', 'CONSTRAINT', N'DF_ProductInventory_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', 'CONSTRAINT', N'DF_ProductInventory_Quantity'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of NEWID()', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', 'CONSTRAINT', N'DF_ProductInventory_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Location.LocationID.', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', 'CONSTRAINT', N'FK_ProductInventory_Location_LocationID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', 'CONSTRAINT', N'FK_ProductInventory_Product_ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', 'CONSTRAINT', N'PK_ProductInventory_ProductID_LocationID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Production', 'TABLE', N'ProductInventory', 'INDEX', N'PK_ProductInventory_ProductID_LocationID'
GO
