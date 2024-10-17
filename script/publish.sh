#!/bin/sh
. "$(dirname $0)/env.sh"

. "$script_dir"/init_melos.sh
cd "$ROOT"
melos publish -y --no-dry-run
