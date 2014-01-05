[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
  [string]$solution,
	
   [Parameter(Mandatory=$True, Position=2)]
   [string]$nugetFolder
)
#if ($args.Count -ne 1)
#{
#    Write-Host "usage create-package <project_file>";
#    Exit;
#}

#$solution = "c:\projects\appccelerate\repos\fundamentals\source\appccelerate.fundamentals.sln"  #$args[0];
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

nuget pack $nuspec -outputDirectory $nugetFolder -symbols -version $version 
