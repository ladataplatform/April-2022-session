CREATE TABLE [Sales].[CountryRegionCurrency]
(
[CountryRegionCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CurrencyCode] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_CountryRegionCurrency_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Sales].[CountryRegionCurrency] ADD CONSTRAINT [PK_CountryRegionCurrency_CountryRegionCode_CurrencyCode] PRIMARY KEY CLUSTERED ([CountryRegionCode], [CurrencyCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CountryRegionCurrency_CurrencyCode] ON [Sales].[CountryRegionCurrency] ([CurrencyCode]) ON [PRIMARY]
GO
ALTER TABLE [Sales].[CountryRegionCurrency] ADD CONSTRAINT [FK_CountryRegionCurrency_CountryRegion_CountryRegionCode] FOREIGN KEY ([CountryRegionCode]) REFERENCES [Person].[CountryRegion] ([CountryRegionCode])
GO
ALTER TABLE [Sales].[CountryRegionCurrency] ADD CONSTRAINT [FK_CountryRegionCurrency_Currency_CurrencyCode] FOREIGN KEY ([CurrencyCode]) REFERENCES [Sales].[Currency] ([CurrencyCode])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cross-reference table mapping ISO currency codes to a country or region.', 'SCHEMA', N'Sales', 'TABLE', N'CountryRegionCurrency', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'ISO code for countries and regions. Foreign key to CountryRegion.CountryRegionCode.', 'SCHEMA', N'Sales', 'TABLE', N'CountryRegionCurrency', 'COLUMN', N'CountryRegionCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ISO standard currency code. Foreign key to Currency.CurrencyCode.', 'SCHEMA', N'Sales', 'TABLE', N'CountryRegionCurrency', 'COLUMN', N'CurrencyCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Sales', 'TABLE', N'CountryRegionCurrency', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Sales', 'TABLE', N'CountryRegionCurrency', 'CONSTRAINT', N'DF_CountryRegionCurrency_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing CountryRegion.CountryRegionCode.', 'SCHEMA', N'Sales', 'TABLE', N'CountryRegionCurrency', 'CONSTRAINT', N'FK_CountryRegionCurrency_CountryRegion_CountryRegionCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Currency.CurrencyCode.', 'SCHEMA', N'Sales', 'TABLE', N'CountryRegionCurrency', 'CONSTRAINT', N'FK_CountryRegionCurrency_Currency_CurrencyCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Sales', 'TABLE', N'CountryRegionCurrency', 'CONSTRAINT', N'PK_CountryRegionCurrency_CountryRegionCode_CurrencyCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nonclustered index.', 'SCHEMA', N'Sales', 'TABLE', N'CountryRegionCurrency', 'INDEX', N'IX_CountryRegionCurrency_CurrencyCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Sales', 'TABLE', N'CountryRegionCurrency', 'INDEX', N'PK_CountryRegionCurrency_CountryRegionCode_CurrencyCode'
GO
