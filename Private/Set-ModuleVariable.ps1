Function Set-ModuleVariable
{
    [cmdletbinding()]
    Param(
        # VariableName help description
        [Parameter(ValueFromPipeline,Mandatory)]
        [string]$VariableName,

        [Parameter(Mandatory)]
        [string]$Value,

        # I don't know of a use case for a 'local' variable, so I didn't include it
        # We scope to script-level variables by default, as they will be available to functions within
        #     the module, but they are not exposed to the user.
        # If there is a variable that needs to be exposed to the user, you should set the scope to global
        [ValidateSet("Global","Script")]
        [string]$Scope = 'Script',

        [string]$Path = "$Script:ModuleBase\lib\Variables.csv",

        [switch]$Force
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"

        $ExistingVariables = @()

        # If the file already exists...
        if ( Test-Path -Path $Path) {

            # Get a list of all the variables already in the CSV
            $ExistingVariables = Import-Csv -Path $Path
        } else {
            Write-Verbose 'Variable file not found'
        }

        # Check if the variable already exists
        if ($ExistingVariables | Where-Object {$_.VariableName -eq $VariableName}) {
            Write-Verbose "Updating existing variable"
            ($ExistingVariables | Where-Object {$_.VariableName -eq $VariableName}).Value = $Value
            ($ExistingVariables | Where-Object {$_.VariableName -eq $VariableName}).Scope = $Scope
        } else {
            Write-Verbose "Creating new variable:"
            Write-Verbose "$VariableName"
            Write-Verbose "$Value"
            Write-Verbose "$Scope"
            $ExistingVariables += [PSCustomObject]@{
                VariableName = $VariableName
                Value = $Value
                Scope = $Scope
            }
        }

        Write-Verbose "Trying to export variables to $Path"

        Try {
            $ExistingVariables | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $Path -Force:$Force -ErrorAction Stop
            Write-Verbose "Trying to update value of $VariableName in memory"
            Set-Variable -Name $VariableName -Value $Value -Scope $Scope -Verbose:$Verbose
        } Catch {
            $_
        }

    } #begin
} #close Set-ModuleVariable