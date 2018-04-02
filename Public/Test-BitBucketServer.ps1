<#
.SYNOPSIS
    Tests access to the api on the BitBucket server.
.DESCRIPTION
    This command is used to verify access to the API on the BitBucket server
.EXAMPLE
    Test-BitBucketServer
.EXAMPLE
    Test-BitBucketServer -Url http://localhost:7990
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
