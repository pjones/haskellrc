#!/usr/bin/env bash

################################################################################
# Run some pre-release checks on the current repository.
set -eu
set -o pipefail

# Keep `cabal' from polluting the global state:
remove_cabal_dir=0

cleanup() {
  if [ "$remove_cabal_dir" -eq 1 ]; then
    rm -r "$CABAL_DIR"
  fi
}
trap cleanup EXIT

if [ -z "${CABAL_DIR:-}" ]; then
  remove_cabal_dir=1
  CABAL_DIR=$(mktemp --directory .cabal.XXXXXXXXXX)
  export CABAL_DIR
fi

cabal_cache=$CABAL_DIR/packages/hackage.haskell.org/01-index.cache

if [ ! -e "$cabal_cache" ] || [ -z "$(find "$cabal_cache" -mmin -60)" ]; then
  # Index is too old, update it.
  cabal update
fi

# Does the package look okay?
if cabal check | head -1 | grep -viq "^No errors or warnings"; then
  cabal check
  exit 1
fi

# Do we have any lint recommendations?
if type -f hlint >/dev/null 2>&1; then
  hlint --no-summary .
else
  curl -sSL https://raw.github.com/ndmitchell/hlint/master/misc/run.sh |
    sh -s -- --no-summary .
fi

# Are there any unbounded packages?
if cabal gen-bounds | grep --fixed-strings '>='; then
  echo >&2 "ERROR: Update dependency bounds listed above"
  exit 1
fi
