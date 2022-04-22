CREATE TABLE [Sales].[SpecialOffer]
(
[SpecialOfferID] [int] NOT NULL IDENTITY(1, 1),
[Description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DiscountPct] [smallmoney] NOT NULL CONSTRAINT [DF_SpecialOffer_DiscountPct] DEFAULT ((0.00)),
[Type] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Category] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [datetime] NOT NULL,
[EndDate] [datetime] NOT NULL,
[MinQty] [int] NOT NULL CONSTRAINT [DF_SpecialOffer_MinQty] DEFAULT ((0)),
[MaxQty] [int] NULL,
[rowguid] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_SpecialOffer_rowguid] DEFAULT (newid()),
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SpecialOffer_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Sales].[SpecialOffer] ADD CONSTRAINT [CK_SpecialOffer_DiscountPct] CHECK (([DiscountPct]>=(0.00)))
GO
ALTER TABLE [Sales].[SpecialOffer] ADD CONSTRAINT [CK_SpecialOffer_EndDate] CHECK (([EndDate]>=[StartDate]))
GO
ALTER TABLE [Sales].[SpecialOffer] ADD CONSTRAINT [CK_SpecialOffer_MaxQty] CHECK (([MaxQty]>=(0)))
GO
ALTER TABLE [Sales].[SpecialOffer] ADD CONSTRAINT [CK_SpecialOffer_MinQty] CHECK (([MinQty]>=(0)))
GO
ALTER TABLE [Sales].[SpecialOffer] ADD CONSTRAINT [PK_SpecialOffer_SpecialOfferID] PRIMARY KEY CLUSTERED ([SpecialOfferID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_SpecialOffer_rowguid] ON [Sales].[SpecialOffer] ([rowguid]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sale discounts lookup table.', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Group the discount applies to such as Reseller or Customer.', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'COLUMN', N'Category'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Discount description.', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Discount precentage.', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'COLUMN', N'DiscountPct'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Discount end date.', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'COLUMN', N'EndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Maximum discount percent allowed.', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'COLUMN', N'MaxQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Minimum discount percent allowed.', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'COLUMN', N'MinQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'COLUMN', N'rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key for SpecialOffer records.', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'COLUMN', N'SpecialOfferID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Discount start date.', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'COLUMN', N'StartDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Discount type category.', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'COLUMN', N'Type'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [DiscountPct] >= (0.00)', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'CONSTRAINT', N'CK_SpecialOffer_DiscountPct'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [EndDate] >= [StartDate]', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'CONSTRAINT', N'CK_SpecialOffer_EndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [MaxQty] >= (0)', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'CONSTRAINT', N'CK_SpecialOffer_MaxQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [MinQty] >= (0)', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'CONSTRAINT', N'CK_SpecialOffer_MinQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'CONSTRAINT', N'DF_SpecialOffer_DiscountPct'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'CONSTRAINT', N'DF_SpecialOffer_MinQty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'CONSTRAINT', N'DF_SpecialOffer_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of NEWID()', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'CONSTRAINT', N'DF_SpecialOffer_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'CONSTRAINT', N'PK_SpecialOffer_SpecialOfferID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'INDEX', N'AK_SpecialOffer_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Sales', 'TABLE', N'SpecialOffer', 'INDEX', N'PK_SpecialOffer_SpecialOfferID'
GO
