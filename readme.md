# MsBuild Task: Auto increment version on build
This is a script to be used on PreBuild events. It will, according to the parameters passed, update the .csproj versioning info.

This script will read a csproj file and update the version info for Assembly, File and/or Package.
For now (and the foreseeable future) this script only support semantic versioning using Major.Minor.Build.Revision syntax.

- The pattern for increment versioning is:
    - = (equal): do not change version
    - \+ (plus): increment version by one.

This means that if you use: =.+.=.+ the script will update the minor version and the revision on each build.

# How to use
## Add the following in your .csproj
Consider that your script is in: ```[solution folder]\BuidTasks```
```xml
    <Target Name="PreBuild" BeforeTargets="PreBuildEvent">        
        <Exec Command="powershell.exe -ExecutionPolicy Bypass -NoProfile -NonInteractive -File ..\BuildTasks\Set-VersionTask.ps1  -projectFile $(ProjectPath) -assemblyVersion =.=.=.+ -fileVersion =.=.=.+ -packageVersion =.=.=.+" />
    </Target>
```

In the snippet above, we're setting the script AssemblyVersion, FileVersion and PackageVersion to autoincrement revision number on each build.
With the exception of -projectFile flag, the rest is optional.
