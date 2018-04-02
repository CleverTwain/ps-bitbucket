<#
.SYNOPSIS
    Create new repository under given project
.DESCRIPTION

.PARAMETER Project
    Mandatory - Bitbucket Project ID
.PARAMETER Repository
    Mandatory - New Repository name to be created
Note: all below command work if -WithGitFlowBranch is passed to True.
.PARAMETER WithGitFlowBranch
    Optional - Switch if repo to have develop/master branch with GitIgnore file - Default set to false
.PARAMETER GitIgnoreFileLoc
    Optional - if WithGitFlowBranch is set to true, then make sure you have a git ignore file at C:\Temp\.gitignore or
    pass the different location with -GitIgnoreFileLoc
.PARAMETER ForkEnabled
    Optional - This is to set repository with fork enabled (true/false). default set to false
.PARAMETER SetDefaultBranch
    Optional - bydefault Master branch is set to default, to change default branch as develop, pass -SetDefaultBranch
.PARAMETER SetBranchPermission
    Optional - Set Master/Develop branch permission as attached screenshot
    to change the permission level/pattern/branch, have your own json file with permission leverl set similar to one available at Public\BranchPermission.json
    Pass the json file path with param -BranchPermissionJson <FileName>
.PARAMETER BranchPermissionJson
    Optional - BranchPermissionJson custom file path
.EXAMPLE
    New-BitBucketRepo -Project "TES" -Repository "ABC"
#>
function New-BitBucketRepo {
    [CmdletBinding()]param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Project,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Repository,

        [Parameter(Mandatory=$false)]
        [switch]$WithGitFlowBranch = $false,

        [Parameter(Mandatory=$false)]
        [string]$GitIgnoreFileLoc= "$Script:ModuleBase\lib\.gitignore",

        [Parameter(Mandatory=$false)]
        [string]$RepoLocalPath= "C:\Git",

        [switch]$PushExisting,

        [Parameter(Mandatory=$false)]
        [switch]$ForkEnabled,

        [Parameter(Mandatory=$false)]
        [switch]$UseHTTP = $Script:UseHttp,

        [Parameter(Mandatory=$false)]
        [switch]$SetDefaultBranch= $false,

        [Parameter(Mandatory=$false)]
        [switch]$SetBranchPermission= $false,

        [Parameter(Mandatory=$false)]
        [string]$BranchPermissionJson = "$Script:ModuleBase\lib\BranchPermission.Json",

        [switch]$Force
    )
    try
    {
        if ($ForkEnabled) {
            $GetForked = 'true'
        } else {
            $GetForked = 'false'
        }
        # Check if .gitignore file exist
        if ($WithGitFlowBranch)
        {
            if ([string]::IsNullOrEmpty($script:UserFullName))
            {
                if (git config user.name) {
                    $Script:UserFullName = git config user.name
                } else {
                    Write-Output "[Error:] Username wasnt set, use Set-UserFullNameAndEmail cmdlet to set it"
                    Break;
                }
            }
            if ([string]::IsNullOrEmpty($script:UserEmailAddress))
            {
                if (git config user.email) {
                    $Script:UserEmailAddress = git config user.email
                } else {
                    Write-Output "[Error:] Email wasnt set, use Set-UserFullNameAndEmail cmdlet to set it"
                    Break;
                }
            }
            if (Test-Path $GitIgnoreFileLoc)
            {
                Write-Output "[Info:] Using .gitignore from $GitIgnoreFileLoc"
            }
            else {
                Write-Output "[Error] $GitIgnoreFileLoc file doesn't exist, either create a file at given location or pass different loc with -GitIgnoreFileLoc <filefullpath> "
                Write-Output "WithGitFlowBranch expect a default .gitignore file to add in both branch (master/develop)."
                Break;
            }
        }
        if (-Not (Test-Path $RepoLocalPath))
        {
            New-Item $RepoLocalPath -Type Directory -Force:$Force
        }
        if (-Not (Test-Path $RepoLocalPath\$Repository))
        {
            New-Item $RepoLocalPath\$Repository -Type Directory -Force:$Force
        }

        $JsonBody = @{
            name        = $Repository
            scmId       = 'git'
            forkable    = $GetForked
        } | ConvertTo-Json

        $Manifest = Invoke-BitBucketWebRequest -Resource "projects/$Project/repos" -Method Post -Body $JsonBody
        $Results = $Manifest | ConvertFrom-Json

        if ($Results.State -eq "AVAILABLE")
        {
            $RepoSlug = $Results.slug
            Write-Output "[Creation][Successful] URL: $script:BitBucketServer/projects/${Project}/repos/${RepoSlug}/browse"
            if (($WithGitFlowBranch) -and (Test-Path $GitIgnoreFileLoc))
            {
                Set-Location $RepoLocalPath\$Repository
                Copy-Item $GitIgnoreFileLoc .
                git init
                git add .gitignore
                git commit -m "Add .gitignore file"
                if ($UseHTTP) {
                    $CloneURL = ($Results.links.clone | Where-Object {$_.Name -eq 'http'}).href
                } else {
                    $CloneURL = ($Results.links.clone | Where-Object {$_.Name -eq 'ssh'}).href
                }
                git remote add origin $CloneURL
                if (!(git config --global credential.helper)) {
                    git config credential.helper $Script:DefaultCredentialHelper
                }
                git branch develop
                git push -u origin --all

                if ($SetDefaultBranch)
                {
                    Set-DefaultBranch -Project "$Project" -Repository "$RepoSlug"
                }
                if ($SetBranchPermission)
                {
                    Set-BranchPermission -Project "$Project" -Repository "$RepoSlug" -BranchPermissionJson "$BranchPermissionJson"
                }
            }
        }
        else {
            Write-Output "[Creation][Failed]"
        }
    }
    catch [System.Exception]
    {
        Write-Output "[Return Message:] $Manifest"
        Throw $_.Exception.Message;
    }
    finally
    {
       #Set-Location  $PSScriptRoot;
    }
}
