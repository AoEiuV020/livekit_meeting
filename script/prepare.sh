#!/bin/sh
. "$(dirname $0)/env.sh"

. "$script_dir"/init_import_sorter.sh
. "$script_dir"/init_melos.sh
cd "$ROOT"
melos bootstrap
