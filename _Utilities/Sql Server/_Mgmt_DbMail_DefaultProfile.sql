use msdb;

--	only setup a dbmail profile if the configuration is enabled
if exists (	select * from sys.configurations where name = N'Database Mail XPs' and value = 1 )
begin
	declare
		@accountId		int
	,	@accountName	sysname	= N'Default Account Name'
	,	@displayName	sysname	= N'Application Name | ' + convert(sysname, serverproperty('MachineName'))
	,	@portNbr		int
	,	@profileId		int
	,	@profileName	sysname	= N'Profile Name'
	,	@sendAsEmail	sysname
	,	@smtpServer		sysname
	,	@replyToEmail	sysname;

	select	@smtpServer		= v.smtpServer
		,	@sendAsEmail	= v.sendAsEmail
		,	@replyToEmail	= v.replyToEmail
		,	@portNbr		= v.portNbr
	from(values	( 'D', N'dev.smtpserver.company.com'	, N'noreply@company.com', N'reply@company.com', 25 )
			,	( 'S', N'dev.smtpserver.company.com'	, N'noreply@company.com', N'reply@company.com', 25 )
			,	( 'P', N'dev.smtpserver.company.com'	, N'noreply@company.com', N'reply@company.com', 25 )
		) v ( Env, smtpServer, sendAsEmail, replyToEmail, portNbr )
	where	v.Env = substring(@@servername, 12, 1);

	--	DB Mail can't be setup if this is a developer workstation.
	if @@rowcount = 0 return;

	set @profileId = ( select profile_id from dbo.sysmail_profile where name = @profileName );

	if @profileId is null
		exec dbo.sysmail_add_profile_sp
					@profile_name	= @profileName
				,	@description	= @profileName
				,	@profile_id		= @profileId output;
	else
		exec dbo.sysmail_update_profile_sp
					@profile_id		= @profileId
				,	@description	= @profileName
	-- Grant access to the profile to the DBMailUsers role  
	if not exists ( select * from dbo.sysmail_principalprofile where profile_id = @profileId )
		exec dbo.sysmail_add_principalprofile_sp
					@profile_id		= @profileId
				,	@principal_name	= N'public'
				,	@is_default		= 1;
	else
		exec dbo.sysmail_update_principalprofile_sp
					@profile_id		= @profileId
				,	@principal_name	= N'public'
				,	@is_default		= 1;

	set @accountId = ( select account_id from dbo.sysmail_account where name = @accountName );

	if @accountId is null
		exec dbo.sysmail_add_account_sp
					@account_name	 = @accountName
				,	@description	 = @displayName
				,	@email_address	 = @sendAsEmail
				,	@display_name	 = @displayName
				,	@replyto_address = @replyToEmail
				,	@mailserver_name = @smtpServer
				,	@port			 = @portNbr
				,	@account_id		 = @accountId output;
	else
		exec dbo.sysmail_update_account_sp
					@account_id					= @accountId
				,	@email_address				= @sendAsEmail
				,	@display_name				= @displayName
				,	@replyto_address			= @replyToEmail
				,	@mailserver_name			= @smtpServer
				,	@description				= @displayName
			--	,	@mailserver_type			= null	-- sysname
				,	@port						= @portNbr
			--	,	@username					= null	-- sysname
			--	,	@password					= null	-- sysname
			--	,	@use_default_credentials	= null	-- bit
			--	,	@enable_ssl					= null	-- bit
			--	,	@timeout					= 0		-- int
			--	,	@no_credential_change		= null	-- bit

	if not exists ( select	* from  dbo.sysmail_profileaccount
					where	account_id = @accountId
					and		profile_id = @profileId )
		exec dbo.sysmail_add_profileaccount_sp
					@profile_id		 = @profileId
				,	@account_id		 = @accountId
				,	@sequence_number = 1;
end;
go
