CREATE TABLE [Production].[Location]
(
[LocationID] [smallint] NOT NULL IDENTITY(1, 1),
[Name] [dbo].[Name] NOT NULL,
[CostRate] [smallmoney] NOT NULL CONSTRAINT [DF_Location_CostRate] DEFAULT ((0.00)),
[Availability] [decimal] (8, 2) NOT NULL CONSTRAINT [DF_Location_Availability] DEFAULT ((0.00)),
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Location_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Production].[Location] ADD CONSTRAINT [CK_Location_Availability] CHECK (([Availability]>=(0.00)))
GO
ALTER TABLE [Production].[Location] ADD CONSTRAINT [CK_Location_CostRate] CHECK (([CostRate]>=(0.00)))
GO
ALTER TABLE [Production].[Location] ADD CONSTRAINT [PK_Location_LocationID] PRIMARY KEY CLUSTERED ([LocationID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_Location_Name] ON [Production].[Location] ([Name]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product inventory and manufacturing locations.', 'SCHEMA', N'Production', 'TABLE', N'Location', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Work capacity (in hours) of the manufacturing location.', 'SCHEMA', N'Production', 'TABLE', N'Location', 'COLUMN', N'Availability'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Standard hourly cost of the manufacturing location.', 'SCHEMA', N'Production', 'TABLE', N'Location', 'COLUMN', N'CostRate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key for Location records.', 'SCHEMA', N'Production', 'TABLE', N'Location', 'COLUMN', N'LocationID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Production', 'TABLE', N'Location', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Location description.', 'SCHEMA', N'Production', 'TABLE', N'Location', 'COLUMN', N'Name'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [Availability] >= (0.00)', 'SCHEMA', N'Production', 'TABLE', N'Location', 'CONSTRAINT', N'CK_Location_Availability'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [CostRate] >= (0.00)', 'SCHEMA', N'Production', 'TABLE', N'Location', 'CONSTRAINT', N'CK_Location_CostRate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.00', 'SCHEMA', N'Production', 'TABLE', N'Location', 'CONSTRAINT', N'DF_Location_Availability'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0.0', 'SCHEMA', N'Production', 'TABLE', N'Location', 'CONSTRAINT', N'DF_Location_CostRate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Production', 'TABLE', N'Location', 'CONSTRAINT', N'DF_Location_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Production', 'TABLE', N'Location', 'CONSTRAINT', N'PK_Location_LocationID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index.', 'SCHEMA', N'Production', 'TABLE', N'Location', 'INDEX', N'AK_Location_Name'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Production', 'TABLE', N'Location', 'INDEX', N'PK_Location_LocationID'
GO
