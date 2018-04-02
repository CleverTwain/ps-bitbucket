Function Get-BitBucketProject
{
    [cmdletbinding(
        DefaultParameterSetName='Name'
    )]
    Param(
        # Name help description
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName='Name'
        )]
        [Alias('ProjectName')]
        [string[]]$Name,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName='Key'
        )]
        [string[]]$Key,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName='Id'
        )]
        [int[]]$Id,

        [Parameter()]
        [ValidateSet("Project_Read","Project_Write","Project_Admin")]
        [string]$Permission,

        [Parameter(
            Mandatory = $true,
            ParameterSetName='All'
        )]
        [switch]$All

    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"

        $Result = @()

        $BaseResource = "projects?limit=1000"
        if ($Permission) {
            $BaseResource = "$BaseResource&permission=$Permission"
        }

        if (!$Name) {
            try {

                $AllProjects = (Invoke-BitBucketWebRequest -Resource $BaseResource | ConvertFrom-Json).Values
            }catch {
                if ($_.ErrorDetails) {
                    Write-Error $_.ErrorDetails.Message
                } else {
                    Write-Error $_
                }
            }
        }

    } #begin
    Process {
        if ($Name) {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $Name "
        }
        if ($Key) {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $Key "
        }
        if ($Id) {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $Id "
        }
        if ($All) {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS]"
        }

        if ($Name) {
            foreach ($Project in $Name) {

                try {
                    $URLSafeName = [System.Web.HttpUtility]::UrlEncode($Project)
                    $Result += (Invoke-BitBucketWebRequest -Resource "$BaseResource&name=$URLSafeName" | ConvertFrom-Json).Values
                }catch {
                    if ($_.ErrorDetails) {
                        Write-Error $_.ErrorDetails.Message
                    } else {
                        Write-Error $_
                    }
                }

            }
        }

        if ($All) {
            $Result = $AllProjects
        }

        if ($Key) {
            foreach ($Project in $Key) {
                Write-Verbose "Searching all projects for a key of $Project"
                $Result += $AllProjects | Where-Object {$_.Key -eq $Project}
            }
        }

        if ($Id) {
            foreach ($Project in $Id) {
                Write-Verbose "Searching all projects for an id of $Project"
                $Result += $AllProjects | Where-Object {$_.Id -eq $Project}
            }
        }

    } #process
    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($MyInvocation.MyCommand)"

        foreach ($Item in $Result) {
            $Link = $Item.Links.Self.Href

            [pscustomobject]@{
                PSTypeName = 'PS.BitBucketProject'
                Key = $Item.Key
                Id = $Item.Id
                Name = $Item.Name
                Description = $Item.Description
                Public = $Item.Public
                Type = $Item.Type
                Link = $Link
            }
        }

    } #end
} #close Get-BitBucketProject