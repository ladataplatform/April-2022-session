Clear-Host

Import-Module SqlChangeAutomation


$WorkingFolder  = 'C:\Users\PaulD\Desktop\DevOps\SQL Change Automation\Release'
$Database       = 'AdventureWorks2017'
$Server         = $env:COMPUTERNAME
$DeployUserName = 'DeployUser'
$DeployPassword = '@pass,w0rd'
$DeployPackage  = "C:\Users\PaulD\Desktop\DevOps\Packaging The Artifacts\NuGet\AdventureWorks2017_RgSqlCompare.3.0.20220408.1.nupkg"


$output = Join-Path -Path $WorkingFolder -ChildPath $Database
$null   = New-Item -ItemType Directory -Force -Path $output

# set up the target database
$targetDB = New-DatabaseConnection -ServerInstance $Server -Database $Database -Username $DeployUserName -Password $DeployPassword #-TrustServerCertificate $true

$null = Test-DatabaseConnection -InputObject $targetDB

[string] $scOptions = '-ForceColumnOrder, -ThrowOnFileParseFailed, DisableAndReenableDdlTriggers, IgnoreDatabaseAndServerName, IgnorePermissions, IgnoreSquareBrackets, IgnoreUsersPermissionsAndRoleMemberships, IgnoretSQLt'

# only apply Test objects to the Environments CustomerDB
$ReleaseArtifact = New-DatabaseReleaseArtifact -Source $DeployPackage -Target $targetDB -SQLCompareOptions $scOptions

Export-DatabaseReleaseArtifact -InputObject $ReleaseArtifact -Path $output -Force

$null = Use-DatabaseReleaseArtifact -InputObject $ReleaseArtifact -DeployTo $targetDB -QueryBatchTimeout 120 -Verbose

[string] $content = Get-Content -Path (Join-Path -Path $output -ChildPath 'Update.sql') -Raw
$null = Execute-PwcScaSaveArtifact -Server $Server -Type 'Database Release' -Name 'Update' -Extension 'sql' -Script $content

Write-Host ('  · Saving release change artifacts for {0}' -f $Database)
if (Test-Path -Path (Join-Path -Path $output -ChildPath 'Update.sql') -PathType Leaf) {
    # list the files/folders to compress/archive
    $archive = Join-Path -Path $output -ChildPath '*'
    $null = Compress-Archive -Path $archive -CompressionLevel Optimal -Force -DestinationPath (Join-Path -Path $WorkingFolder -ChildPath ('{0}_update.zip' -f $Database))
    # remove the output from the process
    #$null = Remove-Item -Path $output -Recurse -Force
}

