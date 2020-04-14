<#
.SYNOPSIS
    Compile all AL projects in the folder tree
.DESCRIPTION
    Read all app.json files in the folder tree and compile the apps in order to fullfill dependencies of the apps.
    Dependencies which are not stored as source code in the tree must be placed to output path first as app files.

.EXAMPLE
    PS C:\> Read-ALConfiguration -Path <repopath> | Compile-ALProjectTree -OrderedApps (Get-ALAppOrder -Path <repopath>) -PackagesPath <outputpath> -CertPwd <certpwd> -CertPath <certpath>
    Will read the configuration for the repo (container name etc.) and will create app files in <outputpath> for all apps inside the tree.
    Apps will be signed by selected certificate with given password

.Parameter ContainerName
    Name of the container to use during compilation to get alc.exe etc.

.Parameter CertPath
    Path to certificate for signing the apps. If not defined, apps will not be signed

.Parameter CertPwd
    Password for the signing certificate

.Parameter OrderedApps
    Array of Apps Info objects in order of compilation. You can use Get-ALAppOrder function to get it

.Parameter PackagesPath
    Path where resulting .app files will be stored and which includes dependencies necessary for compiling the apps.

 .Parameter EnableCodeCop
    Add this switch to Enable CodeCop to run

 .Parameter Failon
    Specify if you want Compilation to fail on Error or Warning (Works only if running under Azure DevOps pipeline - $env:TF_BUILD is true)

.Parameter AsmProbingPaths
    Specify paths for Assembly probing when using Addins or external libraries

.Parameter RulesetFile
    File with rulesets to use during compilation
    
#>
function Compile-ALProjectTree
{
    Param (
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $ContainerName,
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $CertPath,
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $CertPwd,
        $OrderedApps,
        $PackagesPath,
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $Password='',
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $Username=$env:USERNAME,
        [ValidateSet('Windows', 'NavUserPassword')]
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $Auth='Windows',
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        [bool]$EnableCodeCop=$True,
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        [bool]$EnableAppSourceCop=$True,
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        [bool]$EnablePerTenantExtensionCop=$True,
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        [bool]$EnableUICop=$True,
        [ValidateSet('none','error','warning')]
        [string]$FailOn = 'error',
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $AppDownloadScript,
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $RulesetFile,
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $AsmProbingPaths


    )
    if (-not $PackagesPath) {
        $PackagesPath = Get-Location
    }
    foreach ($App in $OrderedApps) {
        if ($App.AppPath) {
            Write-Host "**** Compiling $($App.name) ****"
            $AppPath = Split-Path -Path $App.AppPath
            $AppFileName = (Join-Path $PackagesPath "$($App.publisher)_$($App.name)_$($App.version).app")

            if ($Auth -eq 'NavUserPassword') {
                $PWord = ConvertTo-SecureString -String $Password -AsPlainText -Force
                $User = $Username
                $credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User,$PWord
                if ($env:TF_BUILD) {
                    Compile-AppInNavContainer -containerName $ContainerName -appProjectFolder $AppPath -appOutputFolder $PackagesPath -appSymbolsFolder $PackagesPath -AzureDevOps -credential $credentials -EnableCodeCop:$EnableCodeCop -EnableAppSourceCop:$EnableAppSourceCop -EnablePerTenantExtensionCop:$EnablePerTenantExtensionCop -EnableUICop:$EnableUICop -FailOn $FailOn  -rulesetFile $RulesetFile -assemblyProbingPaths $AsmProbingPaths| Out-Null
                } else {
                    Compile-AppInNavContainer -containerName $ContainerName -appProjectFolder $AppPath -appOutputFolder $PackagesPath -appSymbolsFolder $PackagesPath  -credential $credentials -EnableCodeCop:$EnableCodeCop -EnableAppSourceCop:$EnableAppSourceCop -EnablePerTenantExtensionCop:$EnablePerTenantExtensionCop -EnableUICop:$EnableUICop -FailOn $FailOn  -rulesetFile $RulesetFile -assemblyProbingPaths $AsmProbingPaths| Out-Null
                }
            } else {
                if ($env:TF_BUILD) {
                    Compile-AppInNavContainer -containerName $ContainerName -appProjectFolder $AppPath -appOutputFolder $PackagesPath -appSymbolsFolder $PackagesPath -AzureDevOps  -EnableCodeCop:$EnableCodeCop -EnableAppSourceCop:$EnableAppSourceCop -EnablePerTenantExtensionCop:$EnablePerTenantExtensionCop -EnableUICop:$EnableUICop -FailOn $FailOn -rulesetFile $RulesetFile -assemblyProbingPaths $AsmProbingPaths | Out-Null
                } else {
                    Compile-AppInNavContainer -containerName $ContainerName -appProjectFolder $AppPath -appOutputFolder $PackagesPath -appSymbolsFolder $PackagesPath -EnableCodeCop:$EnableCodeCop -EnableAppSourceCop:$EnableAppSourceCop -EnablePerTenantExtensionCop:$EnablePerTenantExtensionCop -EnableUICop:$EnableUICop -FailOn $FailOn  -rulesetFile $RulesetFile -assemblyProbingPaths $AsmProbingPaths | Out-Null
                }
            }

            if ($CertPath) {
                if ($CertPwd) {
                    Write-Host "Signing the app with $CertPath and password inside container..."
                    #& $SignTool sign /f $CertPath /p $CertPwd /t http://timestamp.verisign.com/scripts/timestamp.dll $AppFileName
                    Sign-NAVContainerApp -containerName $ContainerName -appFile $AppFileName -pfxFile $CertPath -pfxPassword (ConvertTo-SecureString -String $CertPwd -AsPlainText -Force)
                } else {
                    if (Test-Path "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\SignTool.exe") {
                        $SignTool = (get-item "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\SignTool.exe").FullName
                    } else {
                        throw "Couldn't find SignTool.exe, please install Windows SDK from https://go.microsoft.com/fwlink/p/?LinkID=2023014"
                    }
                    Write-Host "Signing the app with $CertPath without password (account permissions inside certificate used)..."
                    & $SignTool sign /f $CertPath /t http://timestamp.verisign.com/scripts/timestamp.dll $AppFileName
                }
            }
        } else { #App not found, download
            Download-ALApp -name $App.name -publisher $App.publisher -version $App.version -targetPath $PackagesPath -AppDownloadScript $AppDownloadScript
        }
    }
}
