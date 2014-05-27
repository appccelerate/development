[CmdletBinding()]
Param(
  [Parameter(Position=1)]
  [string]$solution,
	
   [Parameter(Position=2)]
   [string]$nugetFolder
)

if (!$solution)
{
    Write-Host "no solution provided, using heuristic"

    $source = Split-Path $MyInvocation.MyCommand.Definition -parent | Split-Path -parent | Split-Path -parent | Split-Path -parent
    $sln = Get-ChildItem -Path $source\* -Include *.sln;
   
    if ($sln -is [io.fileinfo])
    {
        Write-Host "heuristic found solution file = " $sln.FullName
        $solution = $sln.FullName;
    }
    else
    {
        Write-Host "heuristic failed to find solution file. Expected it at " $source
        Exit;
    }
}

if (!$nugetFolder)
{
    $repos = Split-Path $MyInvocation.MyCommand.Definition -parent | Split-Path -parent | Split-Path -parent | Split-Path -parent | Split-Path -parent | Split-Path -parent
    $nugetFolder = Join-Path $repos \NugetPackages
    Write-Host "no nuget folder, using default " $nugetFolder 
}

$project = [io.path]::GetFileNameWithoutExtension($solution);
$folder = [io.directory]::GetParent($solution);
$nuspec = "" + $folder + "\" + $project + ".nuspec";
$version = "0.0.0";

Write-Host "building nuget package for "
Write-Host "solution = " $solution;
Write-Host "base folder = " $folder;
Write-Host "nuspec = " $nuspec;

$location = Get-Location

cd $folder

$version_output = gitflowversion;

$version_json = $version_output -join " " | ConvertFrom-Json

$version = $version_json.NugetVersion

Write-Host "version = " $version;

cd $location

msbuild $solution /verbosity:minimal /p:Configuration=Release

if ($LASTEXITCODE -ne 0)
{
    Write-Host Failed to build
    Exit 17
}

nuget pack $nuspec -outputDirectory $nugetFolder -symbols -version $version 

if ($LASTEXITCODE -ne 0)
{
    Write-Host Failed to build
    Exit 42
}