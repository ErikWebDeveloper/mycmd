#!/bin/bash

SCRIPT_DIR="$HOME/Scripts"

selected=$(
for script in "$SCRIPT_DIR"/*.sh; do
    name=$(basename "$script")

    desc=$(grep '^# DESC:' "$script" | head -1 | sed 's/^# DESC:[[:space:]]*//')

    printf "%-35s %s\n" "$name" "$desc"
done | fzf --height=80% --reverse --prompt="Selecciona un script > "
)

[ -z "$selected" ] && exit 0

script_name=$(echo "$selected" | awk '{print $1}')

bash "$SCRIPT_DIR/$script_name"
