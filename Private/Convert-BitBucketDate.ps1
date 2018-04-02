Function Convert-BitBucketDate
{
    [cmdletbinding()]
    Param(
        # Date help description
        [Parameter(ValueFromPipeline)]
        $BitBucketDate
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"

        Get-Date ([timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddMilliseconds($BitBucketDate)))

    } #begin
} #close Convert-BitBucketDate