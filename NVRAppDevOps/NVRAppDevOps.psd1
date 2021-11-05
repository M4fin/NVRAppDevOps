#
# Module manifest for module 'PSGet_NVRAppDevOps'
#
# Generated by: Kamil Sacek
#
# Generated on: 13.06.2018
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'NVRAppDevOps.psm1'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = 'dc28788e-07b6-42c2-88b0-7cdc5fa6abd6'

# Author of this module
Author = 'Kamil Sacek'

# Company or vendor of this module
CompanyName = 'NAVERTICA a.s.'

# Copyright statement for this module
Copyright = '(c) 2018-2021 Kamil Sacek'

# Description of the functionality provided by this module
Description = 'cmdlets for DevOps for Business Central'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @(
    @{
        ModuleName='BcContainerHelper'
        ModuleVersion='2.0.0'
        Guid='8e034fbc-8c30-446d-bbc3-5b3be5392491'
    }
    )

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = '*'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = '*'

# Variables to export from this module
# VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Version number of this module.
ModuleVersion = '2.0.32'


# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{
        Prerelease = ''

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'PSModule'

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://www.github.com/kine/NVRAppDevOps'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = @'
2.0.32
- Install-ALNugetPackage ExactVersion filter debug

2.0.31
- Install-ALNugetPackage ExactVersion switch to prevent applying DependencyVersion for the main package

2.0.19
- Get-ALAppOrder gets the highest dependency version if multiple dependencies on same app

2.0.15
- Install-ALNugetPackage versionmode Lowest now search for lowest version which is higher or equal to requested version (e.g. requeted 1.2.0.0 will take 1.2.123.0 if lowest)

2.0.14
- Add Upload-FileToShp function for uploading file to sharepoint
        
2.0.10
- Fixing Microsoft dependencies when sandbox artifact used in Compile-AppWithArtifact.ps1 (localization apps not found bug)

2.0.7
- Add Compile-AppWithArtifact, Get-ALCompileFromArtifact and parameter artifactUrl into Compile-ALProjectTree and Get-ALAppOrder to
  support compilation without container

2.0.6
- Add Get-BCModulePathFromArtifact
        
2.0.5
- Fixed way how the SQL libraries are loaded. You need to install SqlServer PS Module (Install-module SqlServer)

2.0.3
- Add support for SQL libraries needed for database manipulation cmdlets as part of Import-BCModulesFromArtifacts

2.0.2
- Add Import-BCModulesFromArtifacts

2.0.0
- Changed dependency on bccontainerhelper
- Add parameter DependencyVersion parameter to Download-ALAppFromNuget
- If LatestMinor used, list the available versions and select the corect version based on Major
- do not download Microsoft apps through download script when compiling
- Add IncludeAppFiles switch to Get-ALAppOrder

1.1.8
- Add Get-BatchWI to get multiple WIs in one call

1.1.7
- Add Expand parameter to Get-WI

1.1.1-1.1.5
- ArtifactUrl support - see https://freddysblog.com/
- Get-WI double api-version bug fix
'@

        # External dependent modules of this module
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable
    
 } # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

