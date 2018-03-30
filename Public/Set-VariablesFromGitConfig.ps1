Function Set-VariablesFromGitConfig
{
    [cmdletbinding()]
    Param(
        # VariableName help description
        [Parameter(ValueFromPipeline)]
        [string[]]$VariableName
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"

        $GitConfigSettings = git config -l --name-only

        if ($GitConfigSettings) {

            foreach ($Item in $GitConfigSettings) {

                Write-Verbose "Setting $Item to $Value"

                # Remove the variable if it exists, to prevent re-creating globally scoped variables
                if (Get-Variable -Name $Item -ErrorAction SilentlyContinue) {
                    Remove-Variable -Name $Item -ErrorAction SilentlyContinue
                }

                # Convert string versions of true and false to boolean versions if needed
                Switch (git config $Item) {
                    'true' {
                        [boolean]$Value = $true
                    }
                    'false' {
                        [boolean]$Value = $false
                    }
                    default {
                        [string]$Value = git config $Item
                    }
                }

                if (! (Get-Variable -Name $Item -ErrorAction SilentlyContinue) ) {
                    Write-Verbose "Creating variable"
                    $Output = New-Variable -Name $Item -Value $Value -Scope Global

                    Write-Output $Output
                }
            }
        }

    } #begin
} #close Set-VariablesFromGitConfig