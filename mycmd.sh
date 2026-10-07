#!/usr/bin/env bash
#
# mycmd — lanzador de scripts con estética cyberpunk cozy
#
set -u

VERSION="2.1.0"
SCRIPT_DIR="${MYCMD_DIR:-$HOME/Scripts}"
EDITOR_CMD="${MYCMD_EDITOR:-${EDITOR:-nano}}"
SELF="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || printf '%s' "$0")"

# ---------------------------------------------------------------- paleta ----
if [[ -t 1 ]]; then
    R=$'\033[0m'
    DIM=$'\033[2m'
    BOLD=$'\033[1m'
    NEON=$'\033[38;5;51m'    # cian neón
    PINK=$'\033[38;5;212m'   # rosa neón
    PURPLE=$'\033[38;5;141m' # violeta
    AMBER=$'\033[38;5;215m'  # ámbar cálido
    GREEN=$'\033[38;5;46m'   # verde éxito
    RED=$'\033[38;5;204m'    # rojo error
    BAND=$'\033[38;5;60m'    # línea tenue
else
    R='' DIM='' BOLD='' NEON='' PINK='' PURPLE='' AMBER='' GREEN='' RED='' BAND=''
fi

FZF_COLORS='bg:#0a0e1c,bg+:#161c33,fg:#cbd2f2,fg+:#ffffff,hl:#ff4d94,hl+:#ff4d94,pointer:#ff79c6,marker:#3ef2d0,prompt:#ffb454,info:#a78bfa,header:#3ef2d0,border:#3a4166,gutter:#0a0e1c,selected-bg:#1d2440,preview-bg:#0d1224,label:#ffb454'

sep() { printf '  %s%s%s\n' "$BAND" '──────────────────────────────────────' "$R"; }

info() { printf '  %s%s%s\n' "$NEON" "$*" "$R"; }
warn() { printf '  %s%s%s\n' "$AMBER" "$*" "$R"; }
err()  { printf '  %s✖ %s%s\n' "$RED" "$*" "$R" >&2; }

# ------------------------------------------------------------- catálogo ----
cmd_list() {
    [[ -d $SCRIPT_DIR ]] || return 0
    local f name desc
    for f in "$SCRIPT_DIR"/*.sh; do
        [[ -e $f ]] || continue
        name=$(basename "$f")
        desc=$(grep -m1 '^# DESC:' "$f" 2>/dev/null | sed 's/^# DESC:[[:space:]]*//')
        printf '%s\t%s\n' "$name" "$desc"
    done
}

count_scripts() {
    local n=0 f
    [[ -d $SCRIPT_DIR ]] || { printf 0; return; }
    for f in "$SCRIPT_DIR"/*.sh; do
        [[ -e $f ]] && n=$((n + 1))
    done
    printf '%d' "$n"
}

find_script() {
    local name="$1"
    [[ -n $name && -f $SCRIPT_DIR/$name ]]
}

# --------------------------------------------------------------- banner ----
banner() {
    printf '\n'
    printf '  %s⚡ %smycmd%s %s·%s %sneon script deck%s %sv%s%s\n' \
        "$NEON" "$BOLD" "$R" "$BAND" "$R" "$PINK" "$R" "$DIM" "$VERSION" "$R"
    sep
    printf '  %s%d%s scripts en línea %s·%s %s%s%s\n' \
        "$GREEN" "$(count_scripts)" "$R" "$BAND" "$R" "$DIM" "$SCRIPT_DIR" "$R"
}

# -------------------------------------------------------------- preview ----
cmd_preview() {
    local name="${1:-}"
    if ! find_script "$name"; then
        printf '  %s⚠ script no encontrado%s\n' "$AMBER" "$R"
        return 0
    fi

    local file="$SCRIPT_DIR/$name" desc lines size when
    desc=$(grep -m1 '^# DESC:' "$file" 2>/dev/null | sed 's/^# DESC:[[:space:]]*//')
    lines=$(wc -l < "$file")
    lines=$((lines))
    size=$(du -h "$file" 2>/dev/null | cut -f1)
    when=$(date -r "$file" '+%Y-%m-%d %H:%M' 2>/dev/null)

    printf '\n  %s⚡ %s%s%s\n' "$NEON" "$BOLD" "$name" "$R"
    [[ -n $desc ]] && printf '  %s%s%s\n' "$PURPLE" "$desc" "$R"
    printf '  %s%s líneas %s·%s %s %s·%s %s%s\n' \
        "$DIM" "$lines" "$BAND" "$R" "${size:-?}" "$BAND" "$R" "${when:-?}" "$R"
    printf '  %s%s%s\n' "$BAND" '──────────────────────────────────────' "$R"

    if command -v bat >/dev/null 2>&1; then
        bat --color=always --style=header,numbers --line-range=1:60 "$file"
    elif command -v batcat >/dev/null 2>&1; then
        batcat --color=always --style=header,numbers --line-range=1:60 "$file"
    else
        nl -ba "$file" | sed -n '1,60p'
    fi
}

# ---------------------------------------------------------------- editor ----
cmd_edit() {
    local name="${1:-}"
    if ! find_script "$name"; then
        err "script no encontrado: ${name:-<vacío>}"
        return 1
    fi
    "$EDITOR_CMD" "$SCRIPT_DIR/$name"
}

# ------------------------------------------------------------ ejecución ----
cmd_run() {
    local name="$1"
    shift

    if ! find_script "$name"; then
        err "script no encontrado: $name  (prueba: $0 --list)"
        return 1
    fi

    local file="$SCRIPT_DIR/$name"
    printf '\n'
    printf '  %s⚡ lanzando%s %s%s%s\n' "$NEON" "$R" "$PINK" "$name" "$R"
    sep

    local rc=0
    if [[ -x $file ]]; then
        "$file" "$@"
    else
        bash "$file" "$@"
    fi
    rc=$?

    printf '\n'
    if ((rc == 0)); then
        printf '  %s✔ %s terminado sin errores%s\n' "$GREEN" "$name" "$R"
    else
        printf '  %s✖ %s devolvió el código %d%s\n' "$RED" "$name" "$rc" "$R"
    fi
    return $rc
}

# ------------------------------------------------------------------ menú ----
ensure_dir() {
    [[ -d $SCRIPT_DIR ]] && return 0
    warn "no encuentro el directorio: $SCRIPT_DIR"
    printf '  ¿quieres crearlo? [s/N] '
    local ans=''
    read -r ans
    if [[ $ans =~ ^[sS]$ ]]; then
        mkdir -p "$SCRIPT_DIR" && info "listo: $SCRIPT_DIR"
        return 0
    fi
    printf '\n'
    warn "añade tus .sh a $SCRIPT_DIR y vuelve a intentarlo"
    exit 1
}

cmd_menu() {
    if ! command -v fzf >/dev/null 2>&1; then
        err "fzf no está instalado"
        printf '  %s  Ubuntu/Debian: sudo apt install fzf%s\n' "$DIM" "$R" >&2
        printf '  %s  Arch:         sudo pacman -S fzf%s\n' "$DIM" "$R" >&2
        printf '  %s  Fedora:       sudo dnf install fzf%s\n' "$DIM" "$R" >&2
        exit 1
    fi

    if [[ ! -t 1 ]]; then
        cmd_list
        return 0
    fi

    ensure_dir
    banner

    if [[ $(count_scripts) -eq 0 ]]; then
        printf '\n'
        warn "aún no hay scripts en $SCRIPT_DIR"
        printf '  %scopia aquí tus .sh con una línea %s# DESC:%s y aparecerán solos%s\n' \
            "$DIM" "$PURPLE" "$DIM" "$R"
        printf '\n'
        return 0
    fi

    local keys=$'  ⏎ ejecutar   esc salir\n  ctrl-e editar   ctrl-r recargar'
    local selected=''
    local -a extra=()
    [[ -n ${MYCMD_FZF_ARGS:-} ]] && read -r -a extra <<<"$MYCMD_FZF_ARGS"

    selected=$(cmd_list | fzf \
        --height=80% \
        --layout=reverse \
        --border=rounded \
        --cycle \
        --info=inline \
        --prompt='❯ ' \
        --pointer='»' \
        --marker='+' \
        --header="$keys" \
        --border-label=' ⚡ mycmd ' \
        --color="$FZF_COLORS" \
        --delimiter=$'\t' \
        --preview="'$SELF' --preview {1}" \
        --preview-window='right,50%,border-left,~2' \
        --bind="ctrl-e:execute('$SELF' --edit {1})" \
        --bind="ctrl-r:reload:$SELF --list" \
        --exit-0 \
        "${extra[@]}")

    if [[ -z $selected ]]; then
        printf '\n'
        return 0
    fi

    local name="${selected%%$'\t'*}"
    name="${name%"${name##*[![:space:]]}"}"
    cmd_run "$name"
}

# ----------------------------------------------------------------- ayuda ----
cmd_help() {
    cat <<EOF
${NEON}⚡ mycmd$R ${DIM}v$VERSION$R ${PINK}·$R neon script deck

  ${BOLD}USO$R
    $0                     menú interactivo (fzf)
    $0 <script> [args...]  ejecuta un script directamente
    $0 --list              lista los scripts (tab: nombre<TAB>descripción)
    $0 --preview <script>  vista previa de un script
    $0 --edit <script>     abre un script en el editor
    $0 --help              esta ayuda
    $0 --version           versión

  ${BOLD}ATAJOS EN EL MENÚ$R
    ↑ ↓ / tab        navegar          escribir      filtrar
    ⏎                ejecutar         ctrl-e        editar script
    ctrl-r           recargar lista   esc           salir

  ${BOLD}VARIABLES$R
    MYCMD_DIR         directorio de scripts (defecto: ~/Scripts)
    MYCMD_EDITOR      editor para ctrl-e (defecto: \$EDITOR o nano)
    MYCMD_FZF_ARGS    argumentos extra para fzf

  ${BOLD}EJEMPLO DE SCRIPT$R
    cat > ~/Scripts/hello.sh <<'SH'
    #!/bin/bash
    # DESC: Mi primer script
    echo "¡hola!"
    SH
EOF
}

# ----------------------------------------------------------------- main ----
case "${1:-}" in
    -h | --help)   cmd_help ;;
    -v | --version) printf 'mycmd %s\n' "$VERSION" ;;
    -l | --list)   cmd_list ;;
    --preview)     shift; cmd_preview "${1:-}" ;;
    --edit)        shift; cmd_edit "${1:-}" ;;
    '')
        cmd_menu
        ;;
    *)
        if find_script "$1"; then
            name="$1"
            shift
            cmd_run "$name" "$@"
        else
            err "script no encontrado: $1  (prueba: $0 --list)"
            exit 1
        fi
        ;;
esac
