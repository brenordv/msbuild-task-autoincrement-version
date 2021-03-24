param (
    [string]$projectFile,
    [string]$assemblyVersion = '=.=.=.=',
    [string]$fileVersion = '=.=.=.=',
    [string]$packageVersion = '=.=.=.='
)
<#
    .SYNOPSIS
    This script will read a csproj file and update the version info for Assembly, File and/or Package.
    For now (and the foreseeable future) this script only support semantic versioning using Major.Minor.Build.Revision syntax.

    The pattern for increment versioning is:
        = (equal): do not change version
        + (plus): increment version by one.

    Attention: If you're using any source control system (like GIT), this will make project files be 
    marked as changed, but this also means that this changes will persist.


    .PARAMETER projectFile
    Full path to the project (.csproj) file. You can get it in msbuild by using $(ProjectPath) variable.

    .PARAMETER assemblyVersion
    Pattern to update AssemblyVersion info. Defaults to =.=.=.= (meaning that nothing will be updated)

    .PARAMETER fileVersion
    Pattern to update FileVersion info. Defaults to =.=.=.= (meaning that nothing will be updated)
    
    .PARAMETER packageVersion
    Pattern to update AssemblyVersion info. Defaults to =.=.=.= (meaning that nothing will be updated)    

    .EXAMPLE
    Updates revision number for Assembly, File and Package
    PS> Set-VersionTask.ps1 -projectFile c:\path\to\Project.csproj -assemblyVersion =.=.=.+ -fileVersion =.=.=.+ -packageVersion =.=.=.+ 

    .EXAMPLE
    Updates revision number only for Assembly
    PS> Set-VersionTask.ps1 -projectFile c:\path\to\Project.csproj -assemblyVersion =.=.=.+

    .LINK
    Repo: https://github.com/brenordv/msbuild-task-autoincrement-version
#>


function Get-UpdatedVersion {
    param(
        [string]$currentVersion,
        [string]$versionPattern
    )
    $fileVersion = [version]$currentVersion
    $vParts = $versionPattern.Split('.')
    $major = $fileVersion.Major
    $minor = $fileVersion.Minor
    $build = $fileVersion.Build
    $revision = $fileVersion.Revision

    if($vParts[0] -eq '+'){
        $major += 1
    } 
    if($vParts[1] -eq '+'){
        $minor += 1
    }
    if($vParts[2] -eq '+'){
        $build += 1
    }
    if($vParts[3] -eq '+'){
        $revision += 1
    }
    return "{0}.{1}.{2}.{3}" -f $major, $minor, $build, $revision
}


$assemblyPattern = '(.*)<AssemblyVersion>(.*)<\/AssemblyVersion>'
$filePattern = '(.*)<FileVersion>(.*)<\/FileVersion>'
$packagePattern = '(.*)<PackageVersion>(.*)<\/PackageVersion>'
(Get-Content $projectFile) | ForEach-Object {
    if($_ -match $assemblyPattern){        
        # When AssemblyVersion line is found
        $newVersion = Get-UpdatedVersion -currentVersion $matches[2] -versionPattern $assemblyVersion
        '{0}<AssemblyVersion>{1}</AssemblyVersion>' -f $matches[1], $newVersion
        
    } elseif($_ -match $filePattern){        
        # When FileVersion line is found
        $newVersion = Get-UpdatedVersion -currentVersion $matches[2] -versionPattern $fileVersion
        '{0}<FileVersion>{1}</FileVersion>' -f $matches[1], $newVersion

     } elseif($_ -match $packagePattern){        
         # When PackageVersion line is found
        $newVersion = Get-UpdatedVersion -currentVersion $matches[2] -versionPattern $packageVersion
        '{0}<PackageVersion>{1}</PackageVersion>' -f $matches[1], $newVersion

    }
     else {
        # When the line does not match any other pattern, just return it.
        $_
    }
} | Set-Content $projectFile

exit 0