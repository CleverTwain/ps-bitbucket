Function Get-GitSettings
{
    [cmdletbinding()]
    Param(
        # VariableName help description
        [Parameter(ValueFromPipeline)]
        [object[]]$VariableName
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"



    } #begin
    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $VariableName "



    } #process
    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($MyInvocation.MyCommand)"



    } #end
} #close Get-GitSettings