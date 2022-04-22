/*
**	Script that validates foreign keys, check and unique constraints/indexes that will be enforced.
**	This is run as part of the DB build process after a merge to master. These scripts are used to
**	validate a deployment will be not fail due to "invalid data".
**	
*/
set nocount on;

declare
	@dot		char(1)	 = char(46)
,	@nl			char(2)	 = char(13)+char(10)
,	@t1			char(1)	 = char(9)
,	@t2			char(2)	 = replicate(char(9), 2)
,	@t3			char(3)	 = replicate(char(9), 6)
,	@today		sysname = format(getdate(), 'yyyy-MM-dd')
,	@utc		sysname	= format(getutcdate(), 'MM/dd/yy h:mm:ss tt UTC')
,	@usr		sysname	= replace(suser_sname(), default_domain() + N'\', N'')
,	@bldId		sysname	= N'$(BuildId)'
,	@template	sysname	= N'$(Template)';


select convert(varchar(max), '/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Date		Developer		Work Item	Description
~~~~~~~~~~	~~~~~~~~~~~~~~	~~~~~~~~~~	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
2019-09-20	P. Hunter		47664		Ensures all constraints are valid before a DB deployment.'
+ concat(@today, @t1, @usr, @t1, @bldId, @t1, @template, ' Constraint script created ', @utc, ' UTC.', @nl) +
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
set nocount on;
declare
	@checks table (result int identity primary key, message varchar(500) not null);
insert	@checks select concat(''Constraint validations from '', @@servername, char(46), db_name(), char(58));')	as script
	union
	all
select	script	= iif(o.id > 1, '', concat(@nl, 'if object_id(''' + o.tablename + ''', ''U'') is not null	--	ensure table exits...', @nl, 'begin', @nl))
				+ concat( @t1, 'if	object_id(''' + o.name + ''') is null	--	check data if the constraint doesn''t exist...', @nl
						, case o.type
							when 'CK'	--	check constraint
								then concat	( @t2, 'if exists (	select * from ', o.tableName, ' where not ', o.definition, ' )', @nl
											, @t3, 'insert @checks select char(9) + ''Cannot enforce ', o.name, ' - (invalid ', replace(o.definition, '''', ''''''), ')'';')
							when 'FK'	--	foreign key
								then concat	( @t1, 'and	object_id(N''', o.definition, ''') is not null		--	the related table must exist', @nl
											, @t2, 'if exists (	select * from ', o.tableName, ' a where not exists (select * from ', o.definition, ' b ', o.condition, ' )', @nl
											, @t3, 'insert @checks select char(9) + ''Cannot enforce ', o.name, ' - (missing parent records)'';')
							when 'UK'	--	unique constraint/index
								then concat	( @t2, 'if exists (	select ', o.definition, ' from ', o.tableName, ' group by ', o.definition, ' having count(1) > 1 )', @nl
											, @t3, 'insert @checks select char(9) + ''Cannot enforce ', o.name, ' - (duplicates records found)'';')
						  end)
				+ case when lead(id) over(partition by o.tableName order by o.id) > 0 then '' else @nl + 'end;' end
from(	select	c.tablename, c.name, c.type, c.definition, c.condition
			,	row_number() over(partition by c.tablename order by c.type, c.name) as id
		from(	select	tableName	= quotename(schema_name(t.schema_id))+@dot+quotename(t.name)
					,	k.name, k.definition, type = 'CK', condition = ''
				from	sys.check_constraints k
				join	sys.tables t on t.object_id = k.parent_object_id and t.is_ms_shipped = 0
				union all
				select	tableName = quotename(schema_name(t.schema_id))+@dot+quotename(t.name)
					,	k.name, definition = quotename(schema_name(r.schema_id))+@dot+quotename(r.name)
					,	type = 'FK', condition	= (select	concat(iif(constraint_column_id = 1, 'where',' and'), ' b.', quotename(b.name), ' = a.', quotename(a.name))
												   from		sys.foreign_key_columns	c
												   join		sys.columns a on c.parent_object_id = a.object_id and c.parent_column_id = a.column_id
												   join		sys.columns b on c.referenced_object_id = b.object_id and c.referenced_column_id = b.column_id
												   where	 c.constraint_object_id = k.object_id for xml path('')) + ')'
												+ coalesce((select	concat(' and a.', quotename(a.name), ' is not null')
															from	sys.foreign_key_columns	c
															join	sys.columns a on c.parent_object_id = a.object_id and c.parent_column_id = a.column_id
															where	c.constraint_object_id = k.object_id for xml path('')),  N'')
				from	sys.foreign_keys k
				join	sys.tables t on t.object_id = k.parent_object_id and t.is_ms_shipped = 0
				join	sys.tables r on r.object_id = k.referenced_object_id and r.is_ms_shipped = 0
				union all
				select	tableName = quotename(schema_name(t.schema_id))+@dot+quotename(t.name)
					,	k.name, definition = stuff((select	', '+quotename(col_name(c.object_id, c.column_id)) from sys.index_columns c
													where	c.object_id = k.object_id and c.index_id = k.index_id
													order by c.key_ordinal for xml path('')), 1, 2, '')
					,	type		= 'UK', condition = ''
				from	sys.indexes	k
				join	sys.tables	t on t.object_id = k.object_id and t.is_ms_shipped = 0
				where	k.is_unique		 = 1
				and		k.is_primary_key = 0
			) c
	)	o
	union
	all
select	convert(varchar(max), 'if object_id(''dbo.DepreciationGroup'') is not null
and object_id(''dbo.DeprGroupDetails'') is not null
begin
	insert	@checks ( message )
	select	concat(char(9), ''DepreciationGroup '', g.DepreciationGroupId, '' has no matching DeprGroupDetails record.'') message
	from	dbo.DepreciationGroup g where not exists (select * from dbo.DeprGroupDetails where DeprGroupId = g.DepreciationGroupId)
		union all
	select	concat(char(9), ''DeprGroupDetails '', d.DeprGroupId, '' has no matching DepreciationGroup record.'') message
	from	dbo.DeprGroupDetails d where not exists (select * from dbo.DepreciationGroup where DepreciationGroupId = d.DeprGroupId);
end;')
from	sys.tables
where	name = N'DepreciationGroup'
	union
	all
select	convert(varchar(max), '
if (select count(result) from @checks) = 1
	select 0 result, message from @checks
		union all
	select 0 result, ''	No errors.'';
else
	select result, message from @checks order by result;
go');
go
