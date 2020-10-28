#!/usr/bin/env bash

################################################################################
# Helper script to release a package to Hackage.
set -eu
set -o pipefail

################################################################################
option_username=PeterJones
option_password_cmd=$(dirname "$0")/haskell-get-hackage-password.sh
option_publish=0
upload_args=()

################################################################################
usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

  -h      This message
  -p      Publish the pacakge after uploading

EOF
}

################################################################################
# Option arguments are in $OPTARG
while getopts "hp" o; do
  case "${o}" in
  h)
    usage
    exit
    ;;

  p)
    option_publish=1
    ;;

  *)
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

################################################################################
# General purpose release checks:
# shellcheck source=haskell-pre-release-checks.sh
. "$(dirname "$0")/haskell-pre-release-checks.sh"

################################################################################
# Sanity checks when publishing:
if [ "$option_publish" -eq 1 ]; then
  if [ -n "$(git status --short)" ]; then
    echo >&2 "ERROR: Git says the current repository is dirty!"
    exit 1
  fi

  if ! git describe --exact-match; then
    echo >&2 "ERROR: The latest commit is not tagged!"
    exit 1
  fi

  upload_args+=("--publish")
fi

################################################################################
# Create a clean sdist and upload it:
cabal clean
tarball=$(cabal sdist | tail -1)

if [ ! -e "$tarball" ]; then
  echo >&2 "ERROR: Whoa, cabal said it created $tarball but that file doesn't exist!"
  exit 1
fi

# Let's do this!
set -x

cabal upload \
  --username="$option_username" \
  --password-command="$option_password_cmd" \
  "${upload_args[@]}" \
  "$tarball"

set +x
