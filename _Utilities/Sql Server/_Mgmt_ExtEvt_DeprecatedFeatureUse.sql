use master;

set nocount on;

declare
	@cmd	nvarchar(max)
,	@errMsg nvarchar(2048)
,	@errNbr int
,	@event	sysname		= N'DeprecatedFeatureUse'
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

set	@cmd = N'use master;
create event session [' + @event + '] on server 
	add event sqlserver.deprecation_announcement
	( action
		( package0.collect_system_time
		, sqlserver.database_id
		, sqlserver.database_name
		, sqlserver.session_id
		, sqlserver.username
		, sqlserver.sql_text
		)
		where ( [sqlserver].[database_id] > ( 4 )		--	exclude system databases and SSISDB
		and		[package0].[not_equal_unicode_string]([sqlserver].[database_name], N''SSISDB''))
	)
,	add event sqlserver.deprecation_final_support
	( action
		( package0.collect_system_time
		, sqlserver.database_id
		, sqlserver.database_name
		, sqlserver.session_id
		, sqlserver.username
		, sqlserver.sql_text
		)
		where ( [sqlserver].[database_id] > ( 4 )		--	exclude system databases and SSISDB
		and		[package0].[not_equal_unicode_string]([sqlserver].[database_name], N''SSISDB''))
	)
	add target package0.event_file
		( set filename		 = N''' + @path + @event + '.xel''
		, max_file_size		 = (102400)
		, max_rollover_files = (3)
		)
with
	( max_memory			= 4096 kb
	, event_retention_mode  = allow_single_event_loss
	, max_dispatch_latency  = 30 seconds
	, max_event_size		= 0 kb
	, memory_partition_mode	= none
	, track_causality		= on
	, startup_state			= off
	);

set @status = ''created'';'

begin try
	if not exists ( select * from sys.dm_xe_sessions where name = @event )
	begin
		--	attempt to create the event session
		--	this will genrate error 25631 if the event has be created but is not running
		exec sys.sp_executesql @cmd, N'@status varchar(25) output', @status output;

		if @status = 'created'
		begin
			--	event created so start
			set @cmd = N'alter event session [' + @event + '] on server state = start; set @status = ''started'';'
			exec sys.sp_executesql @cmd, N'@status varchar(25) output', @status output;
			set @status = 'running';
		end;
	end;
	else
	begin
		begin try
			set @cmd = N'alter event session [' + @event + '] on server state = start; set @status = ''started'';'
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
			set @cmd = N'alter event session [' + @event + '] on server state = start; set @status = ''started'';'
			exec sys.sp_executesql @cmd, N'@status varchar(25) output', @status output;
			set @status = 'running';
			return;
		end try
		begin catch
			set @errMsg = N' Unable to start the XEvent ' + @event + ': ' + error_message();
		end catch;
	end;
	throw 54321, @errMsg, 1;
	return;
end catch;
go
