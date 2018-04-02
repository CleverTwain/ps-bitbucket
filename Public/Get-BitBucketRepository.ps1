Function Get-BitBucketRepository
{
    [cmdletbinding(
        DefaultParameterSetName='RepoName',
        PositionalBinding=$true
    )]
    Param(
        # Name help description
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position=0,
            ParameterSetName='RepoName'
        )]
        [Alias('RepoName','Repository')]
        [string[]]$Name,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position=0,
            ParameterSetName='ProjectName'
        )]
        [string[]]$ProjectName,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position=0,
            ParameterSetName='Id'
        )]
        [int[]]$Id,

        [Parameter(
            Mandatory = $true,
            Position=0,
            ParameterSetName='All'
        )]
        [switch]$All,

        [Parameter()]
        [ValidateSet("Project_Read","Project_Write","Project_Admin")]
        [string]$Permission,

        [Parameter()]
        [ValidateSet("Public","Private")]
        [string]$Visibility

    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"

        $Result = @()

        $BaseResource = "repos?limit=1000"
        if ($Permission) {
            $BaseResource = "$BaseResource&permission=$Permission"
        }

        if ($Visibility) {
            $BaseResource = "$BaseResource&visibility=$Visibility"
        }

        if ($Id -or $All) {
            $AllRepos = (Invoke-BitBucketWebRequest -Resource $BaseResource | ConvertFrom-Json).Values
        }

    } #begin
    Process {
        if ($Name) {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $Name "

            foreach ($Repo in $Name) {
                try {
                    $URLSafeName = [System.Web.HttpUtility]::UrlEncode($Repo)
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

        if ($ProjectName) {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $ProjectName "

            foreach ($Project in $ProjectName) {
                try {
                    $URLSafeName = [System.Web.HttpUtility]::UrlEncode($Project)
                    $Result += (Invoke-BitBucketWebRequest -Resource "$BaseResource&projectname=$URLSafeName" | ConvertFrom-Json).Values
                }catch {
                    if ($_.ErrorDetails) {
                        Write-Error $_.ErrorDetails.Message
                    } else {
                        Write-Error $_
                    }
                }
            }
        }

        if ($Id) {
            foreach ($Project in $Id) {
                $Result += $AllRepos | Where-Object {$_.Id -eq $Project}
            }
        }

        if ($All) {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] All "
            $Result = $AllRepos
        }

    } #process
    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($MyInvocation.MyCommand)"

        foreach ($Item in $Result) {

            $CloneLinks = [pscustomobject]@{
                http = ($Item.Links.Clone | Where-Object {$_.Name -eq 'http'}).href
                ssh = ($Item.Links.Clone | Where-Object {$_.Name -eq 'ssh'}).href
            }

            $Links = [pscustomobject]@{
                Self = $Item.Links.Self.Href
                Clone = $CloneLinks
            }

            $Project = (Get-BitBucketProject -Key $Item.Project.Key)

            $Manifest = Invoke-BitBucketWebRequest  -Resource "projects/$($Item.Project.Key)/repos/$($Item.Slug)/sizes" -APIUrl "$script:BitBucketServer" -APIVersion "" | ConvertFrom-Json
            [int]$intNum = [convert]::ToInt32($Manifest.repository)
            [int]$SizeInKB = ${intNum}/1024

            [pscustomobject]@{
                PSTypeName = 'PS.BitBucketRepository'
                Slug = $Item.Slug
                Id = $Item.Id
                Name = $Item.Name
                ScmID = $Item.ScmID
                State = $Item.State
                StatusMessage = $Item.StatusMessage
                Forkable = $Item.Forkable
                Project = (Get-BitBucketProject -Key $Item.Project.Key)
                SizeInKB = $SizeInKB
                Public = $Item.Public
                Links = $Links
            }
        }

    } #end
} #close Get-BitBucketRepository