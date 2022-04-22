use [master];

--	login is only created for Production environment
declare @user sysname = default_domain() + N'\DevOpsGroup';

if default_domain() = N'PrdDomain'
and @@servername like N'%PrdSQL' -- PRD
begin try

	declare @sqlCmd nvarchar(500) = N'
if suser_id(N''' + @user + N''') is null
	create login [' + @user + N'] from windows
		with  default_database	= [master]
			, default_language	= [us_english];
alter server role [sysadmin] add member [' + @user + N'];';

	if @sqlCmd > N'' exec sys.sp_executesql @sqlCmd;

end try
begin catch
	declare @msg nvarchar(2048) = 'Error in ADGrp~DevOpsGroup.sql Login Script for ' + @user + ': ' + error_message();
	throw 54321, @msg, 1;
end catch;
