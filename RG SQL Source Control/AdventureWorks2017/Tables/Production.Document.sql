CREATE TABLE [Production].[Document]
(
[DocumentNode] [sys].[hierarchyid] NOT NULL,
[DocumentLevel] AS ([DocumentNode].[GetLevel]()),
[Title] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Owner] [int] NOT NULL,
[FolderFlag] [bit] NOT NULL CONSTRAINT [DF_Document_FolderFlag] DEFAULT ((0)),
[FileName] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileExtension] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Revision] [nchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChangeNumber] [int] NOT NULL CONSTRAINT [DF_Document_ChangeNumber] DEFAULT ((0)),
[Status] [tinyint] NOT NULL,
[DocumentSummary] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Document] [varbinary] (max) NULL,
[rowguid] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_Document_rowguid] DEFAULT (newid()),
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Document_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Production].[Document] ADD CONSTRAINT [CK_Document_Status] CHECK (([Status]>=(1) AND [Status]<=(3)))
GO
ALTER TABLE [Production].[Document] ADD CONSTRAINT [PK_Document_DocumentNode] PRIMARY KEY CLUSTERED ([DocumentNode]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_Document_DocumentLevel_DocumentNode] ON [Production].[Document] ([DocumentLevel], [DocumentNode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Document_FileName_Revision] ON [Production].[Document] ([FileName], [Revision]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_Document_rowguid] ON [Production].[Document] ([rowguid]) ON [PRIMARY]
GO
ALTER TABLE [Production].[Document] ADD CONSTRAINT [UQ__Document__F73921F7C5112C2E] UNIQUE NONCLUSTERED ([rowguid]) ON [PRIMARY]
GO
ALTER TABLE [Production].[Document] ADD CONSTRAINT [FK_Document_Employee_Owner] FOREIGN KEY ([Owner]) REFERENCES [HumanResources].[Employee] ([BusinessEntityID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product maintenance documents.', 'SCHEMA', N'Production', 'TABLE', N'Document', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Engineering change approval number.', 'SCHEMA', N'Production', 'TABLE', N'Document', 'COLUMN', N'ChangeNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Complete document.', 'SCHEMA', N'Production', 'TABLE', N'Document', 'COLUMN', N'Document'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Depth in the document hierarchy.', 'SCHEMA', N'Production', 'TABLE', N'Document', 'COLUMN', N'DocumentLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key for Document records.', 'SCHEMA', N'Production', 'TABLE', N'Document', 'COLUMN', N'DocumentNode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Document abstract.', 'SCHEMA', N'Production', 'TABLE', N'Document', 'COLUMN', N'DocumentSummary'
GO
EXEC sp_addextendedproperty N'MS_Description', N'File extension indicating the document type. For example, .doc or .txt.', 'SCHEMA', N'Production', 'TABLE', N'Document', 'COLUMN', N'FileExtension'
GO
EXEC sp_addextendedproperty N'MS_Description', N'File name of the document', 'SCHEMA', N'Production', 'TABLE', N'Document', 'COLUMN', N'FileName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'0 = This is a folder, 1 = This is a document.', 'SCHEMA', N'Production', 'TABLE', N'Document', 'COLUMN', N'FolderFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Production', 'TABLE', N'Document', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Employee who controls the document.  Foreign key to Employee.BusinessEntityID', 'SCHEMA', N'Production', 'TABLE', N'Document', 'COLUMN', N'Owner'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Revision number of the document. ', 'SCHEMA', N'Production', 'TABLE', N'Document', 'COLUMN', N'Revision'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Required for FileStream.', 'SCHEMA', N'Production', 'TABLE', N'Document', 'COLUMN', N'rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'1 = Pending approval, 2 = Approved, 3 = Obsolete', 'SCHEMA', N'Production', 'TABLE', N'Document', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Title of the document.', 'SCHEMA', N'Production', 'TABLE', N'Document', 'COLUMN', N'Title'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [Status] BETWEEN (1) AND (3)', 'SCHEMA', N'Production', 'TABLE', N'Document', 'CONSTRAINT', N'CK_Document_Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of 0', 'SCHEMA', N'Production', 'TABLE', N'Document', 'CONSTRAINT', N'DF_Document_ChangeNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Production', 'TABLE', N'Document', 'CONSTRAINT', N'DF_Document_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of NEWID()', 'SCHEMA', N'Production', 'TABLE', N'Document', 'CONSTRAINT', N'DF_Document_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Employee.BusinessEntityID.', 'SCHEMA', N'Production', 'TABLE', N'Document', 'CONSTRAINT', N'FK_Document_Employee_Owner'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Production', 'TABLE', N'Document', 'CONSTRAINT', N'PK_Document_DocumentNode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index.', 'SCHEMA', N'Production', 'TABLE', N'Document', 'INDEX', N'AK_Document_DocumentLevel_DocumentNode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index. Used to support FileStream.', 'SCHEMA', N'Production', 'TABLE', N'Document', 'INDEX', N'AK_Document_rowguid'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique nonclustered index.', 'SCHEMA', N'Production', 'TABLE', N'Document', 'INDEX', N'IX_Document_FileName_Revision'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Production', 'TABLE', N'Document', 'INDEX', N'PK_Document_DocumentNode'
GO
CREATE FULLTEXT INDEX ON [Production].[Document] KEY INDEX [PK_Document_DocumentNode] ON [AW2016FullTextCatalog]
GO
ALTER FULLTEXT INDEX ON [Production].[Document] ADD ([DocumentSummary] LANGUAGE 1033)
GO
ALTER FULLTEXT INDEX ON [Production].[Document] ADD ([Document] TYPE COLUMN [FileExtension] LANGUAGE 1033)
GO
