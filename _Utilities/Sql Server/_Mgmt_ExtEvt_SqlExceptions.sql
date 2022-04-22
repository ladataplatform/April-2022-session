use master;

set nocount on;

declare
	@cmd	nvarchar(max)
,	@errMsg nvarchar(2048)
,	@errNbr int
,	@event	sysname		= N'SqlExceptions'
,	@path	sysname		= convert(sysname, serverproperty('InstanceDefaultDataPath')) + N'XEventData\'
,	@status varchar(25) = 'initialized';

exec sys.xp_create_subdir @path;

declare @result table (fileExists bit, isDirectory bit, parentExists bit);
insert @result exec sys.xp_fileexist @path;
if not exists (select * from @result where isDirectory = 1)
begin
	set @cmd = N'exec sys.xp_cmdshell ''md "' + @path + N'"''';
	exec sys.sp_executesql @cmd;
end;

delete @result;
insert @result exec sys.xp_fileexist @path;
if not exists (select * from @result where isDirectory = 1)
begin
	set @errMsg = N'Unable to create the folder ' + @path;
	throw 54321, @errMsg, 1;
	return;
end;

set	@cmd = concat(N'use master;
create event session ', @event, N' on server
add event sqlserver.error_reported
	( action( sqlserver.session_server_principal_name
			, sqlserver.client_hostname
			, sqlserver.client_app_name
			, sqlserver.session_id
			, sqlserver.database_name
			, sqlserver.sql_text
			, sqlserver.tsql_frame
			, sqlserver.tsql_stack
			)
		where	severity >= 11
		and not sqlserver.like_i_sql_unicode_string(sqlserver.client_app_name, N''%SQL Server Management Studio%'')
		and not sqlserver.equal_i_sql_unicode_string(sqlserver.database_name, N''NevermindMeDB'')
	)
add target package0.event_file
	( set filename				= N''', @path, @event, N'.xel''
		, max_file_size			= 1
		, max_rollover_files	= 5
	)
	with( max_memory			= 512KB
		, event_retention_mode	= allow_single_event_loss
		, max_dispatch_latency	= 30 seconds
		, max_event_size		= 0KB
		, memory_partition_mode	= none
		, track_causality		= off
		, startup_state			= on
		);

set @status = ''created'';');

begin try
	if not exists ( select * from sys.dm_xe_sessions where name = @event )
	begin
		--	attempt to create the event session
		--	this will genrate error 25631 if the event has be created but is not running
		exec sys.sp_executesql @cmd, N'@status varchar(25) output', @status output;

		if @status = 'created'
		begin
			--	event created so start
			set @cmd = N'alter event session ' + @event + ' on server state = start; set @status = ''started'';'
			exec sys.sp_executesql @cmd, N'@status varchar(25) output', @status output;
			set @status = 'running';
		end;
	end;
	else
	begin
		begin try
			set @cmd = N'alter event session ' + @event + ' on server state = start; set @status = ''started'';'
			exec sys.sp_executesql @cmd, N'@status varchar(25) output', @status output;
			set @status = 'running';
		end try
		begin catch
			select	@errMsg = error_message()
				,	@errNbr = error_number();
			if @errNbr = 25705	-- N'The event session has already been started.'
				return;
			else
			begin
				set @errMsg = N' Unable to start the XEvent ' + @event + ': ' + @errMsg;
				set @errNbr = error_number();
				print @errNbr;
				throw 54321, @errMsg, 1;
				return;
			end;
		end catch;
	end;
end try
begin catch
	select	@errMsg = error_message()
		,	@errNbr = error_number();
	if @errNbr = 25631 --N'The event session, "____", already exists.  Choose a unique name for the event session.'
	begin
		begin try
			set @cmd = N'alter event session ' + @event + ' on server state = start; set @status = ''started'';'
			exec sys.sp_executesql @cmd, N'@status varchar(25) output', @status output;
			set @status = 'running';
			return;
		end try
		begin catch
			set @errMsg = N' Unable to start the XEvent ' + @event + ': ' + error_message();
		end catch;
	end;
	throw 54321, @errMsg, 1;
end catch;
go
