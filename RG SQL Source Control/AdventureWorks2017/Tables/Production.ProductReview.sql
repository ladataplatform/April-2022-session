CREATE TABLE [Production].[ProductReview]
(
[ProductReviewID] [int] NOT NULL IDENTITY(1, 1),
[ProductID] [int] NOT NULL,
[ReviewerName] [dbo].[Name] NOT NULL,
[ReviewDate] [datetime] NOT NULL CONSTRAINT [DF_ProductReview_ReviewDate] DEFAULT (getdate()),
[EmailAddress] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Rating] [int] NOT NULL,
[Comments] [nvarchar] (3850) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductReview_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Production].[ProductReview] ADD CONSTRAINT [CK_ProductReview_Rating] CHECK (([Rating]>=(1) AND [Rating]<=(5)))
GO
ALTER TABLE [Production].[ProductReview] ADD CONSTRAINT [PK_ProductReview_ProductReviewID] PRIMARY KEY CLUSTERED ([ProductReviewID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProductReview_ProductID_Name] ON [Production].[ProductReview] ([ProductID], [ReviewerName]) INCLUDE ([Comments]) ON [PRIMARY]
GO
ALTER TABLE [Production].[ProductReview] ADD CONSTRAINT [FK_ProductReview_Product_ProductID] FOREIGN KEY ([ProductID]) REFERENCES [Production].[Product] ([ProductID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Customer reviews of products they have purchased.', 'SCHEMA', N'Production', 'TABLE', N'ProductReview', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Reviewer''s comments', 'SCHEMA', N'Production', 'TABLE', N'ProductReview', 'COLUMN', N'Comments'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Reviewer''s e-mail address.', 'SCHEMA', N'Production', 'TABLE', N'ProductReview', 'COLUMN', N'EmailAddress'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Production', 'TABLE', N'ProductReview', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product identification number. Foreign key to Product.ProductID.', 'SCHEMA', N'Production', 'TABLE', N'ProductReview', 'COLUMN', N'ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key for ProductReview records.', 'SCHEMA', N'Production', 'TABLE', N'ProductReview', 'COLUMN', N'ProductReviewID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product rating given by the reviewer. Scale is 1 to 5 with 5 as the highest rating.', 'SCHEMA', N'Production', 'TABLE', N'ProductReview', 'COLUMN', N'Rating'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date review was submitted.', 'SCHEMA', N'Production', 'TABLE', N'ProductReview', 'COLUMN', N'ReviewDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the reviewer.', 'SCHEMA', N'Production', 'TABLE', N'ProductReview', 'COLUMN', N'ReviewerName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check constraint [Rating] BETWEEN (1) AND (5)', 'SCHEMA', N'Production', 'TABLE', N'ProductReview', 'CONSTRAINT', N'CK_ProductReview_Rating'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Production', 'TABLE', N'ProductReview', 'CONSTRAINT', N'DF_ProductReview_ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Production', 'TABLE', N'ProductReview', 'CONSTRAINT', N'DF_ProductReview_ReviewDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', 'SCHEMA', N'Production', 'TABLE', N'ProductReview', 'CONSTRAINT', N'FK_ProductReview_Product_ProductID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key (clustered) constraint', 'SCHEMA', N'Production', 'TABLE', N'ProductReview', 'CONSTRAINT', N'PK_ProductReview_ProductReviewID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nonclustered index.', 'SCHEMA', N'Production', 'TABLE', N'ProductReview', 'INDEX', N'IX_ProductReview_ProductID_Name'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Clustered index created by a primary key constraint.', 'SCHEMA', N'Production', 'TABLE', N'ProductReview', 'INDEX', N'PK_ProductReview_ProductReviewID'
GO
CREATE FULLTEXT INDEX ON [Production].[ProductReview] KEY INDEX [PK_ProductReview_ProductReviewID] ON [AW2016FullTextCatalog]
GO
ALTER FULLTEXT INDEX ON [Production].[ProductReview] ADD ([Comments] LANGUAGE 1033)
GO
