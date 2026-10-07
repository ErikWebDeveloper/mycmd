# ⚡ mycmd

**Un lanzador de scripts con estética cyberpunk cozy para Linux.**
Hecho con **Bash** + **fzf**: pantalla de neón, panel de vista previa y tus scripts siempre a un `Enter` de distancia.

```text
╭───────────────────────────────────────── ⚡ mycmd ─────────────────────────────────────────╮
│ ❯ backup  < 2/7 ────────────────────────── │   ⚡ backup.sh                                │
│     ⏎ ejecutar   esc salir                 │   Copia de seguridad del servidor            │
│     ctrl-e editar   ctrl-r recargar        │   12 líneas · 4,0K · 2026-10-01 09:14        │
│ » backup.sh  Copia de seguridad            │   ───────────────────────────────────────     │
│ ▌ update.sh  Actualiza el sistema          │      1  #!/bin/bash                          │
│                                           │      2  # DESC: Copia de seguridad            │
│                                           │      3  rsync -av /datos /backup/             │
╰───────────────────────────────────────────────────────────────────────────────────────────╯
```

---

## Índice

* [Características](#características)
* [Requisitos](#requisitos)
* [Instalación](#instalación)
  * [Git](#git)
  * [wget](#wget)
  * [curl](#curl)
* [Cómo se usa](#cómo-se-usa)
  * [1. Menú interactivo](#1-menú-interactivo)
  * [2. Atajos del menú](#2-atajos-del-menú)
  * [3. Ejecución directa](#3-ejecución-directa-alias-teclas-de-función-scripts)
  * [4. Subcomandos](#4-subcomandos)
* [Añadir tus propios scripts](#añadir-tus-propios-scripts)
* [Personalización](#personalización)
* [Problemas frecuentes](#problemas-frecuentes)
* [Actualizar](#actualizar)
* [Desinstalar](#desinstalar)
* [Prueba rápida](#prueba-rápida)
* [Licencia](#licencia)

---

## Características

* 🌆 Interfaz neón (cian, rosa, ámbar y violeta) con bordes redondeados.
* 🔍 Búsqueda difusa instantánea con `fzf` — filtra por nombre **o** descripción.
* 👁 Panel de vista previa: descripción, tamaño, fecha y las primeras líneas del código.
* ✏️ Edita el script seleccionado con `ctrl-e` sin salir del menú.
* 🔄 `ctrl-r` recarga la lista tras añadir o borrar scripts.
* 🚀 Ejecución directa por nombre, con argumentos, para usar desde alias o teclado.
* 🛡 Manejo amable de errores: directorio inexistente, carpeta vacía, `fzf` ausente, códigos de salida.
* 🎨 Resaltado de sintaxis con `bat`/`batcat` si lo tienes instalado (opcional).

---

## Requisitos

* Bash 4+
* [fzf](https://github.com/junegunn/fzf)

| Distribución | Comando |
|---|---|
| Ubuntu / Debian | `sudo apt install fzf` |
| Arch | `sudo pacman -S fzf` |
| Fedora | `sudo dnf install fzf` |

Opcional (para ver el código con color en el panel de vista previa):

```bash
sudo apt install bat        # en Ubuntu el binario se llama batcat
```

---

## Instalación

### Git

```bash
git clone https://github.com/ErikWebDeveloper/mycmd.git
cd mycmd

chmod +x mycmd.sh
sudo cp mycmd.sh /usr/local/bin/mycmd
```

### wget

```bash
wget https://raw.githubusercontent.com/ErikWebDeveloper/mycmd/main/mycmd.sh
chmod +x mycmd.sh
sudo cp mycmd.sh /usr/local/bin/mycmd
```

### curl

```bash
curl -O https://raw.githubusercontent.com/ErikWebDeveloper/mycmd/main/mycmd.sh
chmod +x mycmd.sh
sudo cp mycmd.sh /usr/local/bin/mycmd
```

Comprueba la instalación:

```bash
mycmd --version
# mycmd 2.1.0
```

---

## Cómo se usa

### 1. Menú interactivo

```bash
mycmd
```

Aparece el mazo de neón: escribe para filtrar, muévete con las flechas y pulsa `⏎` para ejecutar.

### 2. Atajos del menú

| Tecla | Acción |
|---|---|
| `↑` `↓` / `tab` | navegar por la lista |
| escribir | filtrar al vuelo |
| `⏎` | ejecutar el script seleccionado |
| `ctrl-e` | abrir el script en el editor |
| `ctrl-r` | recargar la lista |
| `esc` | salir sin hacer nada |

### 3. Ejecución directa (alias, teclas de función, scripts)

```bash
mycmd backup.sh                 # ejecuta directamente, sin menú
mycmd update.sh --dry-run       # los argumentos van al script
```

### 4. Subcomandos

```bash
mycmd --list                # lista nombre<TAB>descripción (para grep, fzf, etc.)
mycmd --preview backup.sh   # vista previa de un script en terminal
mycmd --edit backup.sh      # abre el script en el editor
mycmd --help                # ayuda completa
mycmd --version             # versión
```

Fuera de una terminal (por ejemplo `mycmd | grep ssh`), `mycmd` imprime la lista en vez de abrir el menú.

---

## Añadir tus propios scripts

`mycmd` lee todos los `.sh` de `~/Scripts` (cámbialo con `MYCMD_DIR`).

```bash
mkdir -p ~/Scripts

cat > ~/Scripts/hello.sh <<'EOF'
#!/bin/bash
# DESC: Mi primer script
echo "¡Hola desde mycmd!"
EOF

chmod +x ~/Scripts/hello.sh
```

La línea `# DESC:` es lo que aparece en la lista y en la vista previa.
Si el directorio no existe, `mycmd` te ofrece crearlo la primera vez.

Estructura esperada:

```text
~/Scripts/
├── backup.sh
├── connect_pi.sh
├── docker-clean.sh
└── update.sh
```

---

## Personalización

| Variable | Qué hace | Ejemplo |
|---|---|---|
| `MYCMD_DIR` | carpeta de scripts (por defecto `~/Scripts`) | `MYCMD_DIR=$HOME/bin mycmd -l` |
| `MYCMD_EDITOR` | editor de `ctrl-e` (por defecto `$EDITOR` o `nano`) | `MYCMD_EDITOR=vim mycmd` |
| `MYCMD_FZF_ARGS` | argumentos extra para `fzf` | `MYCMD_FZF_ARGS="--height=100% --layout=default" mycmd` |

Para cambiar la paleta, edita la variable `FZF_COLORS` al inicio de `mycmd.sh`:

```bash
FZF_COLORS='bg:#0a0e1c,fg:#cbd2f2,hl:#ff4d94,prompt:#ffb454,pointer:#ff79c6,...'
```

Los colores se escriben en hexadecimal `#rrggbb`, así que puedes usar cualquier variante
cyberpunk que te guste (`#00ff9c`, `#ff2fb3`, `#f1fa8c`…).

Definir alias cómodo:

```bash
alias scripts='mycmd'
echo "alias scripts='mycmd'" >> ~/.bashrc
```

---

## Problemas frecuentes

**No abre el menú / sale inmediatamente**
Comprueba que hay una terminal (`tty`) y que `fzf` está instalado: `command -v fzf`.

**Dice que no encuentra `fzf`**

```bash
sudo apt install fzf     # Ubuntu/Debian
```

**No aparecen mis scripts**
Solo se listan archivos `*.sh` del directorio configurado. Verifica con:

```bash
mycmd --list
echo "$MYCMD_DIR"
```

**El panel de vista previa sale sin color**
Instala `bat` (`sudo apt install bat`). Sin él, `mycmd` usa `nl`.

**Los colores se ven raros**
Usa un terminal con 256 colores o truecolor (kitty, alacritty, foot, wezterm, gnome-terminal…).
Comprueba con: `echo $TERM` (debería ser algo como `xterm-256color`).

---

## Actualizar

```bash
cd mycmd && git pull
sudo cp mycmd.sh /usr/local/bin/mycmd
```

## Desinstalar

```bash
sudo rm /usr/local/bin/mycmd
```

Tus scripts de `~/Scripts` no se tocan.

---

## Prueba rápida

```bash
mkdir -p ~/Scripts
cat > ~/Scripts/test.sh <<'EOF'
#!/bin/bash
# DESC: Script de prueba
echo "Hola desde mycmd"
EOF
chmod +x ~/Scripts/test.sh

mycmd
```

---

## Licencia

MIT License.
