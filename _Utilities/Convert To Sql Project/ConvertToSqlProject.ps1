Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

Clear-Host

$dbfolder = 'C:\Users\PaulD\Desktop\DevOps\MS SQL Script Option\AdventureWorks2017\Option 2'


$lastFolder = $dbfolder.Split('\')
$lastFolder = $lastFolder[$lastFolder.Count - 1]

$null = Get-ChildItem -Path $dbfolder -Recurse | ForEach-Object { if (Test-Path $_.FullName -PathType Container) { Remove-Item -Recurse -Path $_.FullName } }

[int] $items = 0
$files = $null
$files = Get-ChildItem -Path $dbfolder -Filter '*.sql' `
				|	Select-Object @{Name="baseName"	; Expression={$_.BaseName}}  `
								, @{Name="extension"; Expression={$_.Extension}} `
								, @{Name="fullName"	; Expression={$_.FullName}}
foreach ($file in $files) {
	$fullName = $file.fullName
	$baseName = $file.baseName
	$extend	  = $file.extension
	$type	  = $baseName.split('.')
	$type     = $type[$type.length - 1]
	$baseName = $baseName.Replace(".$type", $extend)
	$target	  = Join-Path $dbfolder -ChildPath "$type"
	if (-not(Test-Path $target -PathType Container)) { $j = New-Item $target -ItemType Directory }
	Move-Item -Path $fullName -Destination "$target\$baseName" -Force
	$items++
}

Write-Host "Processed $Items files in ..\$lastFolder folder."
