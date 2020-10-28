#!/usr/bin/env bash

set -eu
set -o pipefail

# shellcheck source=haskell-pre-merge-checks.sh
. "$(dirname "$0")/haskell-pre-merge-checks.sh"

# Are any dependencies out of date?
if ! cabal outdated --exit-code |
  (grep latest || :) |
  sort --unique; then
  echo >&2 "ERROR: Update dependency bounds listed above"
  exit 1
fi
