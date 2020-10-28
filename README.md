# Peter's Haskell Config Files and Scripts

This repository contains some boring configuration files (e.g.,
`~/.ghci`) and some slightly more interesting scripts.

## Maintainer Scripts

  * `haskell-pre-merge-checks.sh`: Check a package for any mistakes
    before allowing a branch to merge.

  * `haskell-pre-release-checks.sh`: All of the checks from the
    pre-merge script plus additional checks needed before sending a
    release to Hackage.

  * `haskell-release.sh`: Run all of the checks above then upload a
    package to Hackage.

Eventually all of these scripts will be turned into a single Haskell
executable for running locally and in CI/CD.
