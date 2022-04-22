CREATE TABLE [Sales].[SalesTerritory]
(
[TerritoryID] [int] NOT NULL IDENTITY(1, 1),
[Name] [dbo].[Name] NOT NULL,
[CountryRegionCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Group] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SalesYTD] [money] NOT NULL CONSTRAINT [DF_SalesTerritory_SalesYTD] DEFAULT ((0.00)),
[SalesLastYear] [money] NOT NULL CONSTRAINT [DF_SalesTerritory_SalesLastYear] DEFAULT ((0.00)),
[CostYTD] [money] NOT NULL CONSTRAINT [DF_SalesTerritory_CostYTD] DEFAULT ((0.00)),
[CostLastYear] [money] NOT NULL CONSTRAINT [DF_SalesTerritory_CostLastYear] DEFAULT ((0.00)),
[rowguid] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_SalesTerritory_rowguid] DEFAULT (newid()),
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesTerritory_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Sales].[SalesTerritory] ADD CONSTRAINT [CK_SalesTerritory_CostLastYear] CHECK (([CostLastYear]>=(0.00)))
GO
ALTER TABLE [Sales].[SalesTerritory] ADD CONSTRAINT [CK_SalesTerritory_CostYTD] CHECK (([CostYTD]>=(0.00)))
GO
ALTER TABLE [Sales].[SalesTerritory] ADD CONSTRAINT [CK_SalesTerritory_SalesLastYear] CHECK (([SalesLastYear]>=(0.00)))
GO
ALTER TABLE [Sales].[SalesTerritory] ADD CONSTRAINT [CK_SalesTerritory_SalesYTD] CHECK (([SalesYTD]>=(0.00)))
GO
ALTER TABLE [Sales].[SalesTerritory] ADD CONSTRAINT [PK_SalesTerritory_TerritoryID] PRIMARY KEY CLUSTERED ([TerritoryID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_SalesTerritory_Name] ON [Sales].[SalesTerritory] ([Name]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_SalesTerritory_rowguid] ON [Sales].[SalesTerritory] ([rowguid]) ON [PRIMARY]
GO
ALTER TABLE [Sales].[SalesTerritory] ADD CONSTRAINT [FK_SalesTerritory_CountryRegion_CountryRegionCode] FOREIGN KEY ([CountryRegionCode]) REFERENCES [Person].[CountryRegion] ([CountryRegionCode])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sales territory lookup table.', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Business costs in the territory the previous year.', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'COLUMN', N'CostLastYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Business costs in the territory year to date.', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'COLUMN', N'CostYTD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ISO standard country or region code. Foreign key to CountryRegion.CountryRegionCode. ', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'COLUMN', N'CountryRegionCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Geographic area to which the sales territory belong.', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'COLUMN', N'Group'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sales territory description', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'COLUMN', N'Name'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'COLUMN', N'rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sales in the territory the previous year.', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'COLUMN', N'SalesLastYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sales in the territory year to date.', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'COLUMN', N'SalesYTD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key for SalesTerritory records.', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'COLUMN', N'TerritoryID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [CostLastYear] >= (0.00)', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'CONSTRAINT', N'CK_SalesTerritory_CostLastYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [CostYTD] >= (0.00)', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'CONSTRAINT', N'CK_SalesTerritory_CostYTD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [SalesLastYear] >= (0.00)', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'CONSTRAINT', N'CK_SalesTerritory_SalesLastYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [SalesYTD] >= (0.00)', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'CONSTRAINT', N'CK_SalesTerritory_SalesYTD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'CONSTRAINT', N'DF_SalesTerritory_CostLastYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'CONSTRAINT', N'DF_SalesTerritory_CostYTD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'CONSTRAINT', N'DF_SalesTerritory_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of NEWID()', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'CONSTRAINT', N'DF_SalesTerritory_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'CONSTRAINT', N'DF_SalesTerritory_SalesLastYear'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'CONSTRAINT', N'DF_SalesTerritory_SalesYTD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing CountryRegion.CountryRegionCode.', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'CONSTRAINT', N'FK_SalesTerritory_CountryRegion_CountryRegionCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'CONSTRAINT', N'PK_SalesTerritory_TerritoryID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index.', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'INDEX', N'AK_SalesTerritory_Name'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'INDEX', N'AK_SalesTerritory_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Sales', 'TABLE', N'SalesTerritory', 'INDEX', N'PK_SalesTerritory_TerritoryID'
GO
