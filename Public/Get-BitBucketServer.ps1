<#
.SYNOPSIS
    Returns the currently used BitBucket Server URL.
.DESCRIPTION
    This cmdlet is a simple getter function for Set-BitBucketServer cmdlet.
.EXAMPLE
    Get-BitBucketServer
#>
function Get-BitBucketServer {

    if ($Script:BitBucketServer) {
        Write-Verbose "Gathering information from $($Script:BitBucketServer)"
        $Result = Invoke-BitBucketWebRequest -Resource 'application-properties'

        $Json = $Result | ConvertFrom-Json
        if ($Result.StatusCode -eq 200) {
            Write-Verbose "Received response from server"
            $BuildDate = Convert-BitBucketDate -BitBucketDate $Json.BuildDate
            $Object = [pscustomobject]@{
                PSTypeName = 'PS.BitBucketServer'
                Url = $Script:BitBucketServer
                Version = $Json.Version
                BuildNumber = $Json.BuildNumber
                BuildDateEpoch = $Json.BuildDate
                BuildDate = $BuildDate
                DisplayName = $Json.DisplayName
            }

            Write-Output $Object
        } else {
            Write-Output $Result
        }
    } else {
        Write-Warning "BitBucket server not found. Configure via Set-BitBucketServer"
    }
}
