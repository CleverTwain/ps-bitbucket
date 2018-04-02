# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

- Reorganized the file layout
- Added Test-BitBucketServer to test access to the BitBucket API
- Created a Variables.csv file where certain settings can be saved between uses
- Added -Save ability to Set-BitBucketCredential which will save the credential to the Variables.csv file
      - Note that it should only be used for testing as basic credentials can be converted to plaintext
- Updated .gitignore for module to exclude the Variables.csv file so confidential information won't be made public
- Reworked Get-BitBucketProject
      - You can now find a project by name, key, or id
- Reworked Get-BitBucketRepository
      - You can now find a repository by name, slug, id, or project
      - The objects that are returned now include the size of the repository
- Various commands now check if global git settings exist before forcing you to create them
      - If global settings are not found, the Variables.csv file is checked first
- Moved functionality of Get-BitBucketServerInfo to Get-BitBucketServer
- Added new command named Set-VariablesFromGitConfig
      - This command creates a global variable using the name a value of a specified Git variable
- Probably other stuff that I am forgetting...

## [1.1.3] - 2018-02-06

### Added in [1.1.3]

- Add new function to create branch `New-CreateBranch`

### Changed in [1.1.3]

-some of output variables

## [1.1.2] - 2017-12-07

- Few changes in manifest and readme for uploading on psgallery

## [1.0.1] - 2017-11-03

### Added in [1.0.1]

- New options for `New-BitBucketRepo`

Create repo with gitflow branch, set default branch, set branch permission

- `Set-BranchPermission` cmdlet
- `Set-DeafultBranch` cmdlet
- `Set-UserFullNameAndEmail` cmdlet - This is required in order to get correct user display name while commit
- Update wiki page for all feature
- More info about these changes in [Readme.md][wiki]

### Changed in [1.0.1]

- None

### Removed

- None

## 1.0.0 - 2017-11-01

### Added

- Initial commit of my work, includes below cmdlet to start with
1. `Set-BitBucketServer`
2. `Get-BitBucketServer`
3. `Set-BitBucketCredential`
4. `Get-BitBucketAllRepo`
5. `Get-BitBucketRepoByProject`
6. `Get-BitBucketProjects`
7. `Get-BitBucketRepoSizeByProject`
8. `Get-BitBucketAllRepoSize`
9. `New-BitBucketRepo`

[wiki]: https://github.com/i9shankar/ps-bitbucket/blob/master/README.md