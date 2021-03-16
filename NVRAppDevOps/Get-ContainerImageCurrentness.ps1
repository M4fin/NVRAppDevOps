<# 
.Synopsis
    Get currentness of a local container image
.Description
    Gets the installed version of a local image 
.Parameter Image
    The complete image with image name and version
.Example
    Get-ContainerImageCurrentness -Image "mcr.microsoft.com/businesscentral/sandbox:ltsc2019"
#>
function Get-ContainerImageCurrentness {
    Param(
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        $Image
    )
    $localImageIsLatest = $False;
    if ((($Image -eq "") -or ($null -eq $Image))) {
        Write-Error "You need to either specify Image or ImageName and ImageTag";
    } else {
        # https://regexr.com/4l9vu
        $pattern = [regex]'([--:\w?@%&+~#=]*\.[a-z]{2,4}\/{0,2})((?:[?&](?:\w+)=(?:\w+))+|[--:\w?@%&+~#=]+)?';
        $matches = $Image | Select-String -Pattern $pattern -AllMatches;
        $result = $matches.Matches.Groups[2].Value.Split(':');
        $Registry = $matches.Matches.Groups[1].Value.Split('/')[0];
        $ImageName = $result[0];
        $ImageTag = $result[1];
        if ($ImageTag -eq '') {
            $ImageTag = 'latest'
        }
        $Image = $Registry + "/" + $ImageName + ":" + $ImageTag;
        try {
            $manifestUri = "https://$Registry/v2/$ImageName/manifests/$ImageTag";
            $manifestWebRequest = Invoke-WebRequest -Uri $manifestUri -Method Get;
            $manifestContent = [System.Text.Encoding]::ASCII.GetString($manifestWebRequest.RawContentStream.ToArray());
            $manifestJsonObj = $manifestContent | ConvertFrom-Json;
            $manifestHistory = $manifestJsonObj.history;
            try {
                $localImageInspectJson = docker inspect $Image;
                $localImageInspectObj = $localImageInspectJson | ConvertFrom-Json;
                $localImageCreated = $localImageInspectObj.Created;

    
                for ($i = 1; $i -lt $manifestHistory.length; $i++) {
                    $manifestCompatibility = $manifestHistory[$i].v1Compatibility | ConvertFrom-Json;
                    $manifestCompatibilityCreated = [DateTime]$manifestCompatibility.created;
                    $ts = New-TimeSpan -Start $localImageCreated -End $manifestCompatibilityCreated;
                    if ($ts.Hours -ge 1) {
                        $localImageIsLatest = $false;
                    }
                }
            } catch 
            {
                $localImageIsLatest = $false
                Write-Host "The image $Image could not be found locally, pulling";
            }
        }
        catch {
            $localImageIsLatest = $false
            Write-Host "Cannot read data about the image from server, rather pulling";
        }
        finally {        
            if ($localImageIsLatest) {
                Write-Host "The local version of the image $image is the latest version";
            }
            else {
                Write-Host "The local version of the image $image is NOT the latest version";
            }   
        }
    }
    return $localImageIsLatest;
}