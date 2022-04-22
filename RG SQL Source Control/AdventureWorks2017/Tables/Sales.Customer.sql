CREATE TABLE [Sales].[Customer]
(
[CustomerID] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[PersonID] [int] NULL,
[StoreID] [int] NULL,
[TerritoryID] [int] NULL,
[AccountNumber] AS (isnull('AW'+[dbo].[ufnLeadingZeros]([CustomerID]),'')),
[rowguid] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_Customer_rowguid] DEFAULT (newid()),
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Customer_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Sales].[Customer] ADD CONSTRAINT [PK_Customer_CustomerID] PRIMARY KEY CLUSTERED ([CustomerID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_Customer_AccountNumber] ON [Sales].[Customer] ([AccountNumber]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_Customer_rowguid] ON [Sales].[Customer] ([rowguid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Customer_TerritoryID] ON [Sales].[Customer] ([TerritoryID]) ON [PRIMARY]
GO
ALTER TABLE [Sales].[Customer] ADD CONSTRAINT [FK_Customer_Person_PersonID] FOREIGN KEY ([PersonID]) REFERENCES [Person].[Person] ([BusinessEntityID])
GO
ALTER TABLE [Sales].[Customer] ADD CONSTRAINT [FK_Customer_SalesTerritory_TerritoryID] FOREIGN KEY ([TerritoryID]) REFERENCES [Sales].[SalesTerritory] ([TerritoryID])
GO
ALTER TABLE [Sales].[Customer] ADD CONSTRAINT [FK_Customer_Store_StoreID] FOREIGN KEY ([StoreID]) REFERENCES [Sales].[Store] ([BusinessEntityID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Current customer information. Also see the Person and Store tables.', 'SCHEMA', N'Sales', 'TABLE', N'Customer', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique number identifying the customer assigned by the accounting system.', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'COLUMN', N'AccountNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key.', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'COLUMN', N'CustomerID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key to Person.BusinessEntityID', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'COLUMN', N'PersonID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'COLUMN', N'rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key to Store.BusinessEntityID', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'COLUMN', N'StoreID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ID of the territory in which the customer is located. Foreign key to SalesTerritory.SalesTerritoryID.', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'COLUMN', N'TerritoryID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'CONSTRAINT', N'DF_Customer_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of NEWID()', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'CONSTRAINT', N'DF_Customer_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Person.BusinessEntityID.', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'CONSTRAINT', N'FK_Customer_Person_PersonID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing SalesTerritory.TerritoryID.', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'CONSTRAINT', N'FK_Customer_SalesTerritory_TerritoryID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Store.BusinessEntityID.', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'CONSTRAINT', N'FK_Customer_Store_StoreID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'CONSTRAINT', N'PK_Customer_CustomerID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index.', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'INDEX', N'AK_Customer_AccountNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'INDEX', N'AK_Customer_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nonclustered index.', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'INDEX', N'IX_Customer_TerritoryID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Sales', 'TABLE', N'Customer', 'INDEX', N'PK_Customer_CustomerID'
GO
