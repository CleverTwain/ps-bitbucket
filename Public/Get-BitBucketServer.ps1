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
        $Script:BitBucketServer
    } else {
        Write-Warning "BitBucket server not found. Configure via Set-BitBucketServer"
    }
}
