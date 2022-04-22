use master;
go
set nocount on;
/*
**	server level configurations
*/
declare
	@cmd		nvarchar(max)	= N''
,	@debug		bit				= 0		--	doesn't execute change scripts when set to 1
,	@env		char(1)			= substring(@@servername, 12, 1)
,	@maxDop		int				= 0
,	@maxMem		int				= 0
,	@minMem		int				= 0
,	@nl			char(2)			= char(13)+char(10)
,	@mbPerSvc	int				= 64	--	MB reserved per ProcessingServer
,	@othMemHogs	int				= 1024	--	MB reserved for "other" services running
,	@output		varchar(max)	= '';

set	@env = case
			when @env like '[DSUQ]'			-- DEV, STG, UAT or QA
				then @env
			when @env = 'P'					--	PRD, UAT or BLD
				then case 
						when @@servername = N'SomeServer001'	then 'U'	--	001 is currently UAT
						when right(@@servername, 3) = N'BLD'	then 'B'	--	BLD is named instance
						else @env end		--	PRD
			else 'L' end					--	local

--	no changes for Build environment
if @env = 'B' return;

with cte_Server as
(	select	cores		= i.cpu_count
		,	nodes		= i.hyperthread_ratio
		,	cpus		= i.cpu_count / i.hyperthread_ratio
		,	serverMb	= ceiling(i.physical_memory_kb / x.mb)
		,	memBrkPt	= 16 * x.mb	-- above this is a "prod" capable server 
		,	memReserve	= (i.cpu_count * x.mb)		--	reserve 1GB/cpu core
						+ (x.svcCount * @mbPerSvc)	--	reserve for processing services
						+ @othMemHogs				--	reserve for other processing hogs from USIT
		,	x.*
	from	sys.dm_os_sys_info i
	cross apply	( select  compatLvl = try_convert(tinyint, serverproperty('ProductMajorVersion')) * 10
						, mb = 1024., pctMin = .25, pctMID = .5, pctMax = .9, svcCount = 12 ) x
)
select	@maxDop	= s.cores / s.nodes
	,	@maxMem	= floor(case when s.serverMb >= s.memBrkPt
								then (s.serverMb * s.pctMax) - s.memReserve
								else (s.serverMb * s.pctMID) end / s.mb) * s.mb
	,	@minMem = floor(case when s.serverMb >= s.memBrkPt
								then (s.serverMb * s.pctMID) - s.memReserve
								else (s.serverMb * s.pctMin) end / s.mb) * s.mb
from	cte_Server s
option(recompile);

select	@cmd += concat('exec sys.sp_configure N''', v.name, '''		, ', v.newValue, ';', @nl)
from(values	( N'show advanced options'			, 1			)	--	on
		,	( N'Ad Hoc Distributed Queries'		, 0			)	--	off
		,	( N'automatic soft-NUMA disabled'	, 0			)	--	off
		,	( N'backup checksum default'		, 1			)	--	on
		,	( N'backup compression default'		, 1			)	--	on
		,	( N'clr strict security'			, 1			)	--	on
		,	( N'cost threshold for parallelism'	, 75		)	--	may be adjusted per environment
		,	( N'filestream access level'		, 2			)	--	enables filestream REQUIRES RESTART OF SQL SERVICE
		,	( N'lightweight pooling'			, 0			)	--	off
		,	( N'max degree of parallelism'		, @maxDop	)	--	depends on cpu/core count
		,	( N'max server memory (MB)'			, @maxMem	)	--	adjusted per environment
		,	( N'min server memory (MB)'			, @minMem	)	--	adjusted per environment
		,	( N'optimize for ad hoc workloads'	, 1			)	--	true
		,	( N'Ole Automation Procedures'		, 0			)	--	off
		,	( N'priority boost'					, 0			)	--	off
		,	( N'remote admin connections'		, 0			)	--	off
		,	( N'xp_cmdshell'					, 1			)	--	on
	) v ( name, newValue )
join	sys.configurations	c on c.name = v.name
where	c.value_in_use != v.newValue
option(recompile);

if @cmd > N''
begin
	set @cmd += @nl + 'reconfigure with override;' 
	if @debug = 0 exec sys.sp_executesql @cmd;
	select 'Configuration values were updated' msg, @cmd cmd;
end;
else
	select 'All Configuration values are set appropriately' msg

set @cmd = N''
/*
	check on the status of the trace flags
*/
declare @traceStatus table
	( traceFlag	int
	, status	int
	, isGlobal	bit
	, isSession	bit
	);
insert	@traceStatus ( traceFlag, status, isGlobal, isSession ) exec sys.sp_executesql N'dbcc tracestatus with no_infomsgs';

with cte_DesiredFlags as
(	select	traceFlag, status, description	--	these are the flags desired as startup parameters
	from(values	(  174, 1 , 'Increases SSDE plan cache bucket count from 40,000 to 160,001 for 64-bit systems' )
			,	(  460, 1 , 'Returns which column is causing "String or binary data would be truncated" error' )
			,	(  834, 1 , 'CAUTION: not reccommended if using ColumStore Indexes - Use Microsoft Windows large-page allocations for the buffer pool' )
			,	( 1204, 1 , 'Returns resources involved with a deadlock.' )
			,	( 1222, 1 , 'Returns resources involved with a deadlock in XML format.' )
			,	( 2453, 1 , 'Helps query optimizer get rowcounts for table variables' )
			,	( 3226, 1 , 'Supress logging of successful db backup message' )
			,	( 3605, 1 , 'Allow recompilations with table variables' )
			,	( 7412, 1 , 'Enables the lightweight profiling infrastructure for live query performance' )
		) v ( traceFlag, status, description )
)
,	cte_Flags as	--	this identifies any differences between the desired state and those needing to be added or turned on
(	select	r.RegistryKey
		,	TraceFlag		= isnull(d.traceFlag, r.TraceFlag)
		,	Status			= isnull(d.Status, 1)
		,	d.Description
		,	Action	= case
						when d.traceFlag = r.TraceFlag
							then 'None'
						when d.traceFlag is null
							then 'Add to CTE?'
						else 'Add to Registry?' end
	from	cte_DesiredFlags d
	full
	join(	select	RegistryKey	= value_name	--	include startup parameters set in Registry
				,	TraceFlag	= convert(int, try_convert(float, substring(convert(varchar(10), value_data), 3, 8)))
			from	sys.dm_server_registry
			where	value_name like N'SQLArg%'
			and		convert(varchar(10), value_data) like N'-T%'
		) r on r.TraceFlag = d.traceFlag
)
--	generate the commands needed to set the current trace flag to the desired state
select	cmd = concat('dbcc traceon(', f.traceFlag ,', -1);')
	,	f.RegistryKey
	,	TraceFlag	= isnull(f.TraceFlag, s.traceFlag)
	,	Status		= isnull(f.Status, s.status )
	,	f.Description
	,	f.Action
from	cte_Flags	 f
full
join	@traceStatus s on s.traceFlag = f.traceFlag
where	@env != 'L'
and	(	s.status != f.status
	or	s.status is null
	or	f.Status is null	)
order by TraceFlag;
go
