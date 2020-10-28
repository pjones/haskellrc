#!/usr/bin/env bash

set -eu
set -o pipefail

password_entry=tech/hackage.haskell.org

pass show "$password_entry" |
  head -1
