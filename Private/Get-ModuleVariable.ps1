Function Get-ModuleVariable
{
    [cmdletbinding()]
    Param(
        # Path help description
        [Parameter(ValueFromPipeline)]
        [string]$Path = "$Script:ModuleBase\lib\Variables.csv",

        [string]$VariableName,

        [switch]$All
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"

        # In order to make modules easier to use, they can be pre-loaded with variables.
        # To avoid releasing confidential information, module-wide variables are stored
        #   in a CSV file in the .\lib directory.
        # The Variables.csv file should contain the name, value, and scope for each variable
        #   used by the commands within the module.
        # If the variable needs to be exposed to the user, the Scope should be set to global,
        #   otherwise the variable will just be available to the module.
        # In my testing, there was no difference between variables in the local scope, versus
        #   the script scope, but I didn't test that much.
        if (Test-Path -Path $Path) {
            $VariablesInCSV = Import-Csv -Path $Path
            Write-Debug "Parsing variables in $Path"
            foreach ($Item in $VariablesInCSV) {

                # Remove the variable if it exists, to prevent re-creating globally scoped variables
                if (Get-Variable -Name ExpandedValue -ErrorAction SilentlyContinue) {
                    Remove-Variable -Name ExpandedValue -ErrorAction SilentlyContinue
                }

                # Convert string versions of true and false to boolean versions if needed
                if ($ExecutionContext.InvokeCommand.ExpandString($Item.Value) -in 'true','false') {
                    [boolean]$ExpandedValue = [System.Convert]::ToBoolean($ExecutionContext.InvokeCommand.ExpandString($Item.Value))
                } else {
                    $ExpandedValue = $ExecutionContext.InvokeCommand.ExpandString($Item.Value)
                }

                if (!$Item.Scope) {
                    $Scope = 'Script'
                } else {
                    $Scope = $Item.Scope
                }

                if (! (Get-Variable -Name $Item.VariableName -ErrorAction SilentlyContinue) ) {
                    Write-Debug "Creating variable"
                    New-Variable -Name $Item.VariableName -Value $ExpandedValue -Scope $Scope
                }
            }

            if ($VariableName) {
                Write-Debug "Found $VariableName"
                Get-Variable -Name $VariableName
            }

            if ($All) {
                Get-Variable | Where-Object {$_.Name -in $VariablesInCSV.VariableName}
            }
        }

    } #begin
} #close Get-ModuleVariable