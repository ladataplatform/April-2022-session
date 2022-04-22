
/*	format and save the @configJson in Source Control... this is your desired state config
	I use a source control folder structure similar to SSMS folders
	i.e.	...\SqlServer\sys.configurations.json
			...\SqlServer\Security\Logins\...
			...\SqlServer\Security\ServerRoles\...
			... etc...
*/
declare
	@configJson nvarchar(max) = (select	c.name as property, c.value from sys.configurations c
								 order by c.name for json auto, root('properties'));

/*	this will show what is different from current set value  */
select	property, vaue
from	openjson(@configJson, '$.properties')
with( property	nvarchar(35) '$.property'
	, vaue		varchar(max) '$.value'	)
	except
select	c.name as property, convert(varchar(max), c.value)
from	sys.configurations c;

/*	this will show what is different from the value in use  */
select	property, vaue
from	openjson(@configJson, '$.properties')
with( property	nvarchar(35) '$.property'
	, vaue		varchar(max) '$.value'	)
	except
select	c.name as property, convert(varchar(max), c.value_in_use)
from	sys.configurations c;


declare 
	@dbConfigJson nvarchar(max);

drop table if exists #dbProperties;

with cte_DatabaseProperties as
(	select	pvt.property
		,	pvt.value
	from(	select	convert(sysname, source_database_id)					as source_database_id					, suser_sname(owner_sid)										as owner_name
				,	convert(sysname, compatibility_level)					as compatibility_level					, convert(sysname, collation_name) 								as collation_name
				,	convert(sysname, user_access_desc
									collate SQL_Latin1_General_CP1_CI_AS) as user_access							, convert(sysname, is_read_only) 								as is_read_only
				,	convert(sysname, is_auto_close_on)						as is_auto_close_on						, convert(sysname, is_auto_shrink_on) 							as is_auto_shrink_on
				,	convert(sysname, state_desc
									collate SQL_Latin1_General_CP1_CI_AS)	as state								, convert(sysname, is_in_standby) 								as is_in_standby
				,	convert(sysname, is_supplemental_logging_enabled)		as is_supplemental_logging_enabled		, convert(sysname, snapshot_isolation_state_desc
																																	collate SQL_Latin1_General_CP1_CI_AS)			as snapshot_isolation_state
				,	convert(sysname, is_read_committed_snapshot_on)			as is_read_committed_snapshot_on		, convert(sysname, d.recovery_model_desc
																																	collate SQL_Latin1_General_CP1_CI_AS)			as recovery_model
				,	convert(sysname, page_verify_option_desc
									collate SQL_Latin1_General_CP1_CI_AS)	as page_verify_option					, convert(sysname, is_auto_create_stats_on) 					as is_auto_create_stats_on
				,	convert(sysname, is_auto_create_stats_incremental_on)	as is_auto_create_stats_incremental_on	, convert(sysname, is_auto_update_stats_on) 					as is_auto_update_stats_on
				,	convert(sysname, is_auto_update_stats_async_on)			as is_auto_update_stats_async_on		, convert(sysname, is_ansi_null_default_on) 					as is_ansi_null_default_on
				,	convert(sysname, is_ansi_nulls_on)						as is_ansi_nulls_on						, convert(sysname, is_ansi_padding_on) 							as is_ansi_padding_on
				,	convert(sysname, is_ansi_warnings_on)					as is_ansi_warnings_on					, convert(sysname, is_arithabort_on) 							as is_arithabort_on
				,	convert(sysname, is_concat_null_yields_null_on)			as is_concat_null_yields_null_on		, convert(sysname, is_numeric_roundabort_on) 					as is_numeric_roundabort_on
				,	convert(sysname, is_quoted_identifier_on)				as is_quoted_identifier_on				, convert(sysname, is_recursive_triggers_on) 					as is_recursive_triggers_on
				,	convert(sysname, is_cursor_close_on_commit_on)			as is_cursor_close_on_commit_on			, convert(sysname, is_local_cursor_default) 					as is_local_cursor_default
				,	convert(sysname, is_fulltext_enabled)					as is_fulltext_enabled					, convert(sysname, is_trustworthy_on)							as is_trustworthy_on
				,	convert(sysname, is_db_chaining_on)						as is_db_chaining_on					, convert(sysname, is_parameterization_forced)					as is_parameterization_forced
				,	convert(sysname, is_master_key_encrypted_by_server)		as is_master_key_encrypted_by_server	, convert(sysname, is_query_store_on) 							as is_query_store_on
				,	convert(sysname, is_published)							as is_published							, convert(sysname, is_subscribed) 								as is_subscribed
				,	convert(sysname, is_merge_published)					as is_merge_published					, convert(sysname, is_distributor) 								as is_distributor
				,	convert(sysname, is_sync_with_backup)					as is_sync_with_backup					, convert(sysname, service_broker_guid)							as service_broker_guid
				,	convert(sysname, is_broker_enabled)						as is_broker_enabled					, convert(sysname, log_reuse_wait_desc
																																	collate SQL_Latin1_General_CP1_CI_AS ) 			as log_reuse_wait
				,	convert(sysname, is_date_correlation_on)				as is_date_correlation_on				, convert(sysname, is_cdc_enabled) 								as is_cdc_enabled
				,	convert(sysname, is_encrypted)							as is_encrypted							, convert(sysname, is_honor_broker_priority_on)					as is_honor_broker_priority_on
				,	convert(sysname, replica_id)							as replica_id							, convert(sysname, group_database_id) 							as group_database_id
				,	convert(sysname, resource_pool_id)						as resource_pool_id						, convert(sysname, default_language_lcid) 						as default_language_lcid
				,	convert(sysname, default_language_name)					as default_language_name				, convert(sysname, default_fulltext_language_lcid)				as default_fulltext_language_lcid
				,	convert(sysname, default_fulltext_language_name)		as default_fulltext_language_name		, convert(sysname, is_nested_triggers_on) 						as is_nested_triggers_on
				,	convert(sysname, is_transform_noise_words_on)			as is_transform_noise_words_on			, convert(sysname, two_digit_year_cutoff) 						as two_digit_year_cutoff
				,	convert(sysname, containment_desc
									collate SQL_Latin1_General_CP1_CI_AS)	as containment							, convert(sysname, target_recovery_time_in_seconds)				as target_recovery_time_in_seconds
				,	convert(sysname, delayed_durability_desc
									collate SQL_Latin1_General_CP1_CI_AS)	as delayed_durability					, convert(sysname, is_memory_optimized_elevate_to_snapshot_on)	as is_memory_optimized_elevate_to_snapshot_on
				,	convert(sysname, is_federation_member)					as is_federation_member					, convert(sysname, is_remote_data_archive_enabled) 				as is_remote_data_archive_enabled
				,	convert(sysname, is_mixed_page_allocation_on)			as is_mixed_page_allocation_on			, convert(sysname, is_temporal_history_retention_enabled) 		as is_temporal_history_retention_enabled
				,	convert(sysname, catalog_collation_type_desc
									collate SQL_Latin1_General_CP1_CI_AS)	as catalog_collation_type				, convert(sysname, physical_database_name) 						as physical_database_name
				,	convert(sysname, is_result_set_caching_on)				as is_result_set_caching_on				, convert(sysname, is_accelerated_database_recovery_on) 		as is_accelerated_database_recovery_on
				,	convert(sysname, is_tempdb_spill_to_remote_store)		as is_tempdb_spill_to_remote_store		, convert(sysname, is_stale_page_detection_on) 					as is_stale_page_detection_on
				,	convert(sysname, is_memory_optimized_enabled)			as is_memory_optimized_enabled
			from	sys.databases d
			where	d.database_id = db_id() ) src
	unpivot(value
			for property in ( [source_database_id]					, [owner_name]									, [compatibility_level]					, [collation_name]
							, [user_access]							, [is_read_only]								, [is_auto_close_on]					, [is_auto_shrink_on]
							, [state]								, [is_in_standby]								, [is_supplemental_logging_enabled]		, [snapshot_isolation_state]
							, [is_read_committed_snapshot_on]		, [recovery_model]								, [page_verify_option]					, [is_auto_create_stats_on]
							, [is_auto_create_stats_incremental_on]	, [is_auto_update_stats_on]						, [is_auto_update_stats_async_on]		, [is_ansi_null_default_on]
							, [is_ansi_nulls_on]					, [is_ansi_padding_on]							, [is_ansi_warnings_on]					, [is_arithabort_on]
							, [is_concat_null_yields_null_on]		, [is_numeric_roundabort_on]					, [is_quoted_identifier_on]				, [is_recursive_triggers_on]
							, [is_cursor_close_on_commit_on]		, [is_local_cursor_default]						, [is_fulltext_enabled]					, [is_trustworthy_on]
							, [is_db_chaining_on]					, [is_parameterization_forced]					, [is_master_key_encrypted_by_server]	, [is_query_store_on]
							, [is_published]						, [is_subscribed]								, [is_merge_published]					, [is_distributor]
							, [is_sync_with_backup]					, [service_broker_guid]							, [is_broker_enabled]					, [log_reuse_wait]
							, [is_date_correlation_on]				, [is_cdc_enabled]								, [is_encrypted]						, [is_honor_broker_priority_on]
							, [replica_id]							, [group_database_id]							, [resource_pool_id]					, [default_language_lcid]
							, [default_language_name]				, [default_fulltext_language_lcid]				, [default_fulltext_language_name]		, [is_nested_triggers_on]
							, [is_transform_noise_words_on]			, [two_digit_year_cutoff]						, [containment]							, [target_recovery_time_in_seconds]
							, [delayed_durability]					, [is_memory_optimized_elevate_to_snapshot_on]	, [is_federation_member]				, [is_remote_data_archive_enabled]
							, [is_mixed_page_allocation_on]			, [is_temporal_history_retention_enabled]		, [catalog_collation_type]				, [physical_database_name]
							, [is_result_set_caching_on]			, [is_accelerated_database_recovery_on]			, [is_tempdb_spill_to_remote_store]		, [is_stale_page_detection_on]
							, [is_memory_optimized_enabled]
							)
			) pvt
)
/*	save this so you can use an except to generate the except between Json and DB	*/
select * into #dbProperties from cte_DatabaseProperties;

/*	format and save the @dbConfigJson in Source Control... this is your desired state config  */
select @dbConfigJson = (select	dp.property, dp.value
							,	iif(dp.property like N'is[_]%', iif(dp.value = '1', N'on', N'off'), value) setting
						from	#dbProperties dp order by dp.property for json auto, root('properties'));
with cte_DesiredState as
(	select	property, value, setting
	from	openjson(@dbConfigJson, '$.properties')	
	with( property	sysname
		, value		varchar(255)
		, setting	varchar(255) )
)
select	ds.property
	,	ds.setting
from(	select	property, value
		from	cte_DesiredState
			--except	--	use except to find the differences
			intersect	--	for demo purposes to show how to find
		select	property, value
		from	#dbProperties ) dif
join	cte_DesiredState ds on ds.property = dif.property;
