declare @FilterTables	nvarchar(max) = null
declare @ExcludeTables	nvarchar(max) = null--'dbo.DatabaseLog,dbo.ErrorLog,dbo.AWBuildVersion';
;
with cte_filter as
(	select	object_id(value) tableId
	from	string_split(nullif(@FilterTables, N''), ',')
		union
	select	object_id
	from	sys.tables
	where	is_ms_shipped	 = 0
	and		name			!= N'sysdiagrams'
	and		@FilterTables	is null
)
,	cte_Relationships as
(	select	parent_object_id	 childId
		,	referenced_object_id parentId
	from	sys.foreign_keys
	where	parent_object_id != referenced_object_id
)
,	cte_Hierarchy as
(	select	t.object_id	tableId
		,	0			Level
	from	sys.tables		  t
	left
	join	cte_Relationships r on t.object_id = r.childId 
	where	t.is_ms_shipped  = 0
	and		t.name			!= N'sysdiagrams'
	and		r.childId		is null
		union
		all
	select	r.childId
		,	h.Level + 1
	from	cte_Relationships	r
	join	cte_Hierarchy		h on h.tableId = r.parentId
)
select	max(h.Level)														as relationLevel
	,	concat(object_schema_name(h.tableId), N'.', object_name(h.tableId))	as tableName
from	cte_filter		f
join	cte_Hierarchy	h on h.tableId = f.tableId
left
join(	select	object_id(value) as excludeId
		from	string_split(@ExcludeTables, ',')) x on f.tableId = x.excludeId
where       x.excludeId is null
group by    h.tableId
order by relationLevel, tableName;