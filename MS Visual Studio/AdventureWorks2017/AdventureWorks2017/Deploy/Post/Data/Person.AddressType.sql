begin try
	set nocount, xact_abort on;

	declare @table	sysname = 'Person.AddressType';
	declare @hasId	bit		= (select count(1) from sys.identity_columns where object_id = object_id(@table));
	declare @temp	nvarchar(2048) = formatmessage(N'set identity_insert %s on;', @table);
	declare @nl		nchar(2)	= nchar(13)+nchar(10);

	declare @output table ( [action] varchar(6) );

	if @hasId = 1 exec sys.sp_executesql @temp;
	
	with Person_AddressType as
	(	select	id, name
		from(values ( 1, 'Home'		)
				,	( 2, 'Office'	)
				,	( 3, 'Vacation'	)
			) v ( id, name )
			except
		select	AddressTypeID, Name collate SQL_Latin1_General_CP1_CS_AS
		from	Person.AddressType
	)
	merge	Person.AddressType with(holdlock) tgt
	using	Person_AddressType src on src.id = tgt.AddressTypeID
	when matched then
		update	set	Name = src.name
	when not matched by target then
		insert	( AddressTypeID
				, Name
				)
		values	( src.id
				, src.name
				)
	when not matched by source then
		delete
	output $action into @output;
	
	if @@rowcount = 0 insert @output values ('None')
	
	set @temp = replace(@temp, N' on;', ' off;');
	if @hasId = 1 exec sys.sp_executesql @temp;

	select	'These updates were applied to ' + @table + ':' + @nl
		+	string_agg(formatmessage(N'	%s - %i', a.action, a.items), @nl)
	from(	select	action, iif(action = 'None', -1, 0) + count(1) items from @output group by action ) a;
	
end try
begin catch
	set @temp = formatmessage('An Error occured on line %i in script %s.' + @nl + 'Error: %s', error_line(), 'Person.AddressType.sql', error_message());
	throw 54321, @temp, 1;
end catch;
go
