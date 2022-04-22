USE AdventureWorks2017;

/*	Add a non-null column that doesn't have a default
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

EXEC sys.sp_help  N'Person.AddressType'

IF COL_LENGTH(N'Person.AddressType', N'CreatedDate') IS NULL
BEGIN
	ALTER TABLE Person.AddressType ADD CreatedDate DATETIME NULL;

	EXEC sys.sp_executesql N'
	UPDATE	Person.AddressType
	SET		CreatedDate = ModifiedDate;'

	EXEC sys.sp_executesql N'ALTER TABLE Person.AddressType ALTER COLUMN CreatedDate DATETIME NOT NULL;'
END;
GO	5

EXEC sys.sp_help  N'Person.AddressType'

/*	Life if messy, clean it up!
	ALTER TABLE Person.AddressType DROP COLUMN CreatedDate
*/





/*	Add a foreign key for new column in an existing table
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

EXEC sys.sp_help  N'Person.AddressType'
EXEC sys.sp_help  N'dbo.NewTable'

DROP TABLE IF EXISTS dbo.NewTable;

IF OBJECT_ID(N'dbo.NewTable', 'U') IS NULL
BEGIN
	EXEC sys.sp_executesql N'
	create table dbo.NewTable
	(	NewTableId		int			not null constraint PK_NewTable primary key
	,	NewTableValue	varchar(20)	not null
	,	CreatedDate		datetime	not null constraint DF_NewTable_CreatedDate default (getdate())
	,	UpdatedDate		datetime		null
	);';
END;
GO	5
IF OBJECT_ID(N'dbo.NewTable', 'U') IS NOT NULL
BEGIN 
	MERGE	dbo.NewTable WITH(HOLDLOCK) tgt
	USING(	SELECT Id, Value
			FROM(VALUES	( 1, 'Value 1' )
					,	( 2, 'Value 2' )
				) lst ( Id, Value )
			) src ON src.Id = tgt.NewTableId
	WHEN MATCHED
		AND src.Value <> tgt.NewTableValue
		THEN
		UPDATE	SET	NewTableValue	= src.Value
				,	UpdatedDate		= GETDATE()
	WHEN NOT MATCHED
		THEN
		INSERT	(	NewTableId
				,	NewTableValue
				,	CreatedDate
				)
		VALUES	(	src.Id
				,	src.Value
				,	GETDATE()
				);
END;
GO	5
IF COL_LENGTH(N'Person.AddressType', N'NewTableId') IS NULL
BEGIN
	ALTER TABLE Person.AddressType ADD NewTableId INT NULL;

	UPDATE	Person.AddressType
	SET		NewTableId = 2 - (AddressTypeId % 2);

	ALTER TABLE Person.AddressType ADD NewTableId INT NOT NULL;
END;
GO 5

/*	Life if messy, clean it up!
	DROP TABLE dbo.NewTable
*/


/*	working with CTE for Reference/Lookup Values & the perils of merge
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

SELECT * FROM Person.AddressType;

with Person_AddressType as
(	select	AddressTypeID, Name, rowguid
	from(values	( 1, N'Billing'		, 'B84F78B1-4EFE-4A0E-8CB7-70E9F112F886' )
			,	( 2, N'HOME'		, '41BC2FF6-F0FC-475F-8EB9-CEC0805AA0F2' )
			,	( 3, N'Main Office'	, '8EEEC28C-07A2-4FB9-AD0A-42D4A0BBC575' )
			--,	( 4, N'Primary'		, '24CB3088-4345-47C4-86C5-17B535133D1E' )
			,	( 5, N'Shipping'	, 'B29DA3F8-19A3-47DA-9DAA-15C84F4A83A5' )
			,	( 6, N'Archive'		, 'A67F238A-5BA2-444B-966C-0467ED9C427F' )
			,	( 7, N'Agent'		, 'E384E707-7D50-4B1F-9992-834DEE56CBF6' )
		) v ( AddressTypeID, Name, rowguid )
)
select AddressTypeID, Name collate SQL_Latin1_General_CP1_CS_AS Name, rowguid from Person_AddressType
		except
select AddressTypeID, Name, rowguid from Person.AddressType;

