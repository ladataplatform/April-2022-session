#	start of script
[cmdletbinding()]
param
( [Parameter(Mandatory=$true)]							[string] $Server
, [Parameter(Mandatory=$true)]							[string] $UserName
, [Parameter(Mandatory=$true)]							[string] $Password
, [ValidateScript({Test-Path $_ -PathType Container})]	[string] $WorkingFolder
, [Parameter(Mandatory=$true)]							[string] $BuildId
, [ValidateSet('Build','Invoke')]						[string] $Action
)

function Set-Environment {
	param
	( [ValidateScript({Test-Path $_ -PathType Container})] $WorkingFolder
	)
	try {
		#	Load any needed modules
		[string[]] $modules = @('SQlServer')
		foreach($module in $modules) {
			if (!(Get-Module -Name $module)) {
				Import-Module $module -DisableNameChecking  -ErrorAction silentlycontinue -ErrorVariable +ImportErrors
			}
		}
		Set-Location $WorkingFolder
	}
	catch { exit-WithError $_.Message }
}

<#
.Synopsis
	Builds the DB Constraint validation script files,

.Description
	Builds/creates DB Constraint Validation scripts using the DBConstraintValidation.sql file.
	The SQL file is a genric script that checks Check, Foreign Key and Unique Constraints/Indexes
	for data that would violate creation of the constraint.

.Parameter Server
	The SQL Server instance which hosts template databases

.Parameter UserName
	UserName having access to the SQL Server instance which hosts template databases

.Parameter Password
	Password for the UserName on the SQL Server instance which hosts template databases

.Parameter WorkingFolder
	Path to the Build.ArtifactStagingDirectory where the source code is saved

.Parameter BuildId
	The Azure DevOps Build.BuildId value ised in naming the NuGet package
#>
function Build-DBConstraintValidation {
	param
	( [Parameter(Mandatory=$true)] [string] $Server
	, [Parameter(Mandatory=$true)] [string] $UserName
	, [Parameter(Mandatory=$true)] [string] $Password
	, [ValidateScript({Test-Path $_ -PathType Container})] [string] $WorkingFolder
	, [Parameter(Mandatory=$true)] [string] $BuildId
	)
	try {
		Set-Environment -WorkingFolder $WorkingFolder

		#	list the template databases used for generating the constraints
		$buildDate	= $(Get-Date).ToUniversalTime()
		$content	= ''
		$databases	= @('CI_CentralDatabase','CI_ClientDatabase','CI_AuditDB','CI_MaintenanceDB')
		$envPrefix	= 'CI_'
		$file		= Join-Path -Path $WorkingFolder -ChildPath 'DBConstraintValidation.ps1'
		$files		= "    <file src=""$file"" target=""content"" />`r`n"
		$nuGet		= Join-Path -Path $WorkingFolder -ChildPath 'NuGet.exe'
		$pkgeName	= 'DBConstraintValidation.nuspec'
		$scriptPath = Join-Path -Path $WorkingFolder -ChildPath 'DBConstraintValidation.sql'

		[string] $query = Get-Content -Path $scriptPath -Delimiter '`r`n'
		$query = $query.Replace('$(BuildId)', $BuildId)

		foreach($database in $databases) {
			$template	= $database.Replace($envPrefix, '')
			$queryEx	= $query.Replace('$(Template)', $template)
			$result		= Invoke-Sqlcmd -ServerInstance $Server -Database $database -Query $queryEx -Username $UserName -Password $Password
			$content	= ''
			foreach($row in $result) { $content += $row.script + "`r`n" }
			$row		= $null		# life is messy - clean it up
			$result		= $null		# life is messy - clean it up
			Write-Host "Creating constraint valdations for Template DB $template"
			$file	 = Join-Path -Path $WorkingFolder -ChildPath "$template$('_ConstraintValidation.sql')"
			$files	+= "    <file src=""$file"" target=""content"" />`r`n"
			$junk	 = New-Item -Path $file -ItemType File -Value $content -Force
			Write-Host $('~' * 80)
		}

		# define the nuspec file
		$content = @"
<?xml version="1.0"?>
<package >
  <metadata>
    <id>DBConstraintValidation</id>
    <version>$($BuildId)</version>
    <authors>Paul D. Hunter</authors>
    <owners>PwC.US.TECS.TDS.TDS</owners>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <description>DB Constraint Validation package created on $buildDate (UTC)</description>
    <releaseNotes>Validates data for any missing Check, Foreign Key and Unique constraints for database indicated by the file name.</releaseNotes>
    <copyright>© 2000-$($(Get-Date).ToString('yy')) · PricewaterhouseCoopers · All rights reserved</copyright>
    <tags />
    <dependencies />
  </metadata>
  <files>
$files  </files>
</package>
"@
		#	create the nuspec file
		$junk = New-Item -Path $(Join-Path -Path $WorkingFolder -ChildPath $pkgeName) -ItemType File -Value $content -Force

		# get a list of files to delete before creating the NuGet package
		$items = Get-ChildItem -Path $WorkingFolder

		Invoke-Expression -command "& ""$nuGet"" pack $pkgeName"

		#	clean up all files except the nuget package
		foreach($file in $items ) { if (!([string]::IsNullOrEmpty($file))) { Remove-Item -Path $file.FullName -Force } }
	}
	catch { exit-WithError $_.Message }
}

<#
.Synopsis
	Invokes the DB Constraint validation scripts against the deployable databases

.Description
	Executes the DB Constraint Validation script sql file for each appropriate.

.Parameter Server
	The SQL Server instance which hosts template databases

.Parameter UserName
	UserName having access to the SQL Server instance which hosts template databases

.Parameter Password
	Password for the UserName on the SQL Server instance which hosts template databases

.Parameter WorkingFolder
	Path to the Build.ArtifactStagingDirectory where the source code is saved
#>
function Invoke-DBConstraintValidation {
	param
	( [Parameter(Mandatory=$true)] [string] $Server
	, [Parameter(Mandatory=$true)] [string] $UserName
	, [Parameter(Mandatory=$true)] [string] $Password
	, [ValidateScript({Test-Path $_ -PathType Container})] [string] $WorkingFolder
	)
	try {
		Set-Environment -WorkingFolder $WorkingFolder

		#	extract contents of NuGet package
		$package = $(Get-ChildItem -Path $WorkingFolder -Filter 'DBConstraintValidation.3.0.*.nupkg' | Select-Object -Last 1).FullName
		Add-Type -AssemblyName System.IO.Compression.FileSystem
		[IO.Compression.ZipFile]::ExtractToDirectory($package, $WorkingFolder)

		$centralDB
		$query		= "select name from sys.databases where name like '%CentralDatabase';"
		$results	= $(Invoke-Sqlcmd -ServerInstance $Server -Database 'master' -Query $query -Username $UserName -Password $Password)
		$centralDB	= $results.name
		if ([string]::IsNullOrEmpty($centralDB)) { thow "The CentralDatabase could not be found for server $Server" }

		$query = @"
select	Position	= 1
	,	DBname		= 'MaintenanceDB'
	,	Template	= 'MaintenanceDB'
	,	d.ServerName
from	dbo.[Database]	d
group by d.ServerName
	union
	all
select	Position	= 2
	,	DBname		= d.name
	,	t.Template
	,	ServerName	= concat_ws(',', @@servername, isnull(s.local_tcp_port, '1433'))
from	sys.databases	d
cross
join(	select N'CentralDatabase' as Template
			union all
		select N'AuditDB' ) t
left
join	sys.dm_exec_connections s on s.session_id = @@spid
where	d.name like N'%' + t.Template
	union
	all
select	Position	= iif(d.DBname like '%ClientDatabase%', 3, 4)
	,	d.DBname
	,	Template	= 'ClientDatabase'
	,	d.ServerName
from	dbo.[Database]	d
where	d.IsDeployable = 1
order by Position, ServerName, DBname;
"@
		$results = $(Invoke-Sqlcmd -ServerInstance $Server -Database $centralDB -Query $query -Username $UserName -Password $Password)
		Write-Host $('~' * 80)
		foreach($row in $results) { 
			$server		= $row.ServerName
			$database	= $row.DBname
			$script		= $(Join-Path -Path $WorkingFolder -ChildPath "content\$($row.Template)_ConstraintValidation.sql")
			try {
				$results = $(Invoke-Sqlcmd -ServerInstance $server -Database $database -InputFile $script -Username $UserName -Password $Password -IncludeSqlUserErrors -OutputSqlErrors $true)
				foreach($row in $results) { Write-Host $row.Validation }
				Write-Host $('~' * 80)
			}
			catch { Write-host $_.Exception }
		}
	}
	catch { exit-WithError $_.Exception }
}

<#
  .Synopsis
	Exit the Release Process with an hard error
	
  .Description
	Centralied process for reporting errors and exiting the script.
	
  .Parameter Exception
	The $Error that occurred and will be reported
	
  .Example
	exit-WithError -Exception $_.Exception
#>
function exit-WithError {
	param ( $Exception )
	try {
		Write-Host $('#' * 80)
		Write-Host " ** Unable to run the PwC DB Constraint Validation Script **"
		Write-Error "##vso[task.logissue type=error;]Exception: $($Exception.ToString())" -Verbose
	}
	catch {
		Write-Host $('#' * 80)
		Write-Host " Error generated in exit-WithError function:"
		Write-Error "##vso[task.logissue type=error;]Exception: $($_.Exception)" -Verbose
	}
	finally {
		Write-Host $('#' * 80)
		exit 1
	}
}

#	main entry point after the script is called with correct parameters.
if ($Action -eq 'Build') {
	Build-DBConstraintValidation -Server $Server -UserName $UserName -Password $Password -WorkingFolder $WorkingFolder -BuildId $BuildId
}
elseif ($Action -eq 'Invoke') {
	Invoke-DBConstraintValidation -Server $Server -UserName $UserName -Password $Password -WorkingFolder $WorkingFolder
}
else {
	throw 'The DBConstraintValidaiton script was called with an invalid Action.'
}
#	end of script