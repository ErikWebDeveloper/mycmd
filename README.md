# mycmd

Un lanzador de scripts sencillo para Linux usando **Bash** y **fzf**.

`mycmd` busca todos los scripts `.sh` almacenados en `~/Scripts`, muestra una lista interactiva con sus descripciones y ejecuta el script seleccionado.

## Características

* 🚀 Ejecuta scripts desde un menú interactivo.
* 🔍 Búsqueda instantánea gracias a `fzf`.
* 📝 Soporte para descripciones de los scripts.
* 🐧 Ligero y sin dependencias complejas.

---

## Requisitos

* Bash
* fzf

### Ubuntu / Debian

```bash
sudo apt install fzf
```

---

## Instalación

### Git

```bash
git clone https://github.com/TU_USUARIO/mycmd.git
cd mycmd

chmod +x mycmd
sudo cp mycmd /usr/local/bin/
```

### wget

```bash
wget https://raw.githubusercontent.com/TU_USUARIO/mycmd/main/mycmd

chmod +x mycmd
sudo mv mycmd /usr/local/bin/
```

### curl

```bash
curl -O https://raw.githubusercontent.com/TU_USUARIO/mycmd/main/mycmd

chmod +x mycmd
sudo mv mycmd /usr/local/bin/
```

Comprueba que está instalado:

```bash
mycmd
```

---

## ¿Cómo funciona?

`mycmd` busca automáticamente todos los scripts con extensión `.sh` dentro de:

```
~/Scripts
```

Cada script puede incluir una descripción mediante un comentario especial:

```bash
# DESC: Conecta al servidor Raspberry
```

Al ejecutar:

```bash
mycmd
```

aparecerá algo parecido a:

```
backup.sh                  Copia de seguridad del servidor
connect_pi.sh              Conecta a la Raspberry
update.sh                  Actualiza el sistema
```

Selecciona un script con las flechas, escribe para filtrar y pulsa Enter para ejecutarlo.

---

## Crear un nuevo script

Crea el directorio si no existe:

```bash
mkdir -p ~/Scripts
```

Ejemplo:

```bash
nano ~/Scripts/hello.sh
```

Contenido:

```bash
#!/bin/bash
# DESC: Mi primer script

echo "¡Hola Mundo!"
```

Dale permisos:

```bash
chmod +x ~/Scripts/hello.sh
```

Ahora aparecerá automáticamente en `mycmd`.

---

## Instalar en el PATH

La forma recomendada es:

```bash
sudo cp mycmd /usr/local/bin/
chmod +x /usr/local/bin/mycmd
```

Verifica la instalación:

```bash
which mycmd
```

Salida esperada:

```
/usr/local/bin/mycmd
```

También puedes instalarlo únicamente para tu usuario:

```bash
mkdir -p ~/.local/bin
cp mycmd ~/.local/bin/
chmod +x ~/.local/bin/mycmd
```

Añade la ruta al PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## Estructura esperada

```
~/Scripts/
├── backup.sh
├── connect_pi.sh
├── docker-clean.sh
└── update.sh
```

Ejemplo de script:

```bash
#!/bin/bash
# DESC: Actualiza el sistema

sudo apt update
sudo apt upgrade -y
```

---

## Actualizar

Si lo instalaste mediante Git:

```bash
git pull
sudo cp mycmd /usr/local/bin/
```

---

## Desinstalar

```bash
sudo rm /usr/local/bin/mycmd
```

Tus scripts almacenados en `~/Scripts` no se eliminarán.

---

## Licencia

MIT License.

---

## Ejemplo rápido

```bash
mkdir -p ~/Scripts

cat > ~/Scripts/test.sh << EOF
#!/bin/bash
# DESC: Script de prueba

echo "Hola desde mycmd"
EOF

chmod +x ~/Scripts/test.sh

mycmd
```

¡Y listo! Tendrás un menú interactivo para ejecutar tus scripts favoritos desde cualquier terminal.
