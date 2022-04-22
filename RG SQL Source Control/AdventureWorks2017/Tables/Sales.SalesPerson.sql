CREATE TABLE [Sales].[SalesPerson]
(
[BusinessEntityID] [int] NOT NULL,
[TerritoryID] [int] NULL,
[SalesQuota] [money] NULL,
[Bonus] [money] NOT NULL CONSTRAINT [DF_SalesPerson_Bonus] DEFAULT ((0.00)),
[CommissionPct] [smallmoney] NOT NULL CONSTRAINT [DF_SalesPerson_CommissionPct] DEFAULT ((0.00)),
[SalesYTD] [money] NOT NULL CONSTRAINT [DF_SalesPerson_SalesYTD] DEFAULT ((0.00)),
[SalesLastYear] [money] NOT NULL CONSTRAINT [DF_SalesPerson_SalesLastYear] DEFAULT ((0.00)),
[rowguid] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_SalesPerson_rowguid] DEFAULT (newid()),
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesPerson_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Sales].[SalesPerson] ADD CONSTRAINT [CK_SalesPerson_Bonus] CHECK (([Bonus]>=(0.00)))
GO
ALTER TABLE [Sales].[SalesPerson] ADD CONSTRAINT [CK_SalesPerson_CommissionPct] CHECK (([CommissionPct]>=(0.00)))
GO
ALTER TABLE [Sales].[SalesPerson] ADD CONSTRAINT [CK_SalesPerson_SalesLastYear] CHECK (([SalesLastYear]>=(0.00)))
GO
ALTER TABLE [Sales].[SalesPerson] ADD CONSTRAINT [CK_SalesPerson_SalesQuota] CHECK (([SalesQuota]>(0.00)))
GO
ALTER TABLE [Sales].[SalesPerson] ADD CONSTRAINT [CK_SalesPerson_SalesYTD] CHECK (([SalesYTD]>=(0.00)))
GO
ALTER TABLE [Sales].[SalesPerson] ADD CONSTRAINT [PK_SalesPerson_BusinessEntityID] PRIMARY KEY CLUSTERED ([BusinessEntityID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_SalesPerson_rowguid] ON [Sales].[SalesPerson] ([rowguid]) ON [PRIMARY]
GO
ALTER TABLE [Sales].[SalesPerson] ADD CONSTRAINT [FK_SalesPerson_Employee_BusinessEntityID] FOREIGN KEY ([BusinessEntityID]) REFERENCES [HumanResources].[Employee] ([BusinessEntityID])
GO
ALTER TABLE [Sales].[SalesPerson] ADD CONSTRAINT [FK_SalesPerson_SalesTerritory_TerritoryID] FOREIGN KEY ([TerritoryID]) REFERENCES [Sales].[SalesTerritory] ([TerritoryID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sales representative current information.', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Bonus due if quota is met.', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'COLUMN', N'Bonus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key for SalesPerson records. Foreign key to Employee.BusinessEntityID', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'COLUMN', N'BusinessEntityID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Commision percent received per sale.', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'COLUMN', N'CommissionPct'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'COLUMN', N'rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sales total of previous year.', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'COLUMN', N'SalesLastYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Projected yearly sales.', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'COLUMN', N'SalesQuota'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sales total year to date.', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'COLUMN', N'SalesYTD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Territory currently assigned to. Foreign key to SalesTerritory.SalesTerritoryID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'COLUMN', N'TerritoryID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [Bonus] >= (0.00)', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'CONSTRAINT', N'CK_SalesPerson_Bonus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [CommissionPct] >= (0.00)', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'CONSTRAINT', N'CK_SalesPerson_CommissionPct'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [SalesLastYear] >= (0.00)', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'CONSTRAINT', N'CK_SalesPerson_SalesLastYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [SalesQuota] > (0.00)', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'CONSTRAINT', N'CK_SalesPerson_SalesQuota'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [SalesYTD] >= (0.00)', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'CONSTRAINT', N'CK_SalesPerson_SalesYTD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'CONSTRAINT', N'DF_SalesPerson_Bonus'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'CONSTRAINT', N'DF_SalesPerson_CommissionPct'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'CONSTRAINT', N'DF_SalesPerson_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of NEWID()', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'CONSTRAINT', N'DF_SalesPerson_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'CONSTRAINT', N'DF_SalesPerson_SalesLastYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'CONSTRAINT', N'DF_SalesPerson_SalesYTD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Employee.EmployeeID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'CONSTRAINT', N'FK_SalesPerson_Employee_BusinessEntityID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing SalesTerritory.TerritoryID.', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'CONSTRAINT', N'FK_SalesPerson_SalesTerritory_TerritoryID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'CONSTRAINT', N'PK_SalesPerson_BusinessEntityID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'INDEX', N'AK_SalesPerson_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Sales', 'TABLE', N'SalesPerson', 'INDEX', N'PK_SalesPerson_BusinessEntityID'
GO
