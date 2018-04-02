<#
.SYNOPSIS
    Returns the currently used BitBucket Server URL.
.DESCRIPTION
    This cmdlet is a simple getter function for Set-BitBucketServer cmdlet.
.EXAMPLE
    Test-BitBucketServer
#>
function Test-BitBucketServer {
    param(
        [Parameter(
            Mandatory=$false,
            HelpMessage="Fully qualified HTTP endpoint for the target BitBucket Server. http://localhost:7990"
            )]
        [ValidatePattern('^(https?:\/\/)([\w\.-]+)(:\d+)*\/*')]
        [string]$Url = $Script:BitBucketServer
    )

    if ($Url) {
        Invoke-BitBucketWebRequest -Resource 'application-properties' -Server $Url

    } else {
        Write-Warning "BitBucket server not found. Configure via Set-BitBucketServer"
    }
}
