# ── Monitores ──────────────────────────────────────────────────────────────
# para ver tus monitores y sus nombres: hyprctl monitors | grep Monitor
# o con: xrandr | grep " connected"
MONITORS=(
  "DP-1:Izquierdo"
  #"DP-2:Centro" podes agregar o reconfigurar como desees
  #"DP-3:Derecho"
)

# ── Wallpaper Engine ───────────────────────────────────────────────────────
# revisar documentacion (https://github.com/Almamu/linux-wallpaperengine/blob/main/README.md)
# o en la terminal linux-wallpaperengine --help
# para ver todos los argumentos posibles

FPS=30
WE_ARGS=(--silent --disable-mouse)

# ── Paths ──────────────────────────────────────────────────────────────────
# estos estan comunmente en el mismo disco que la carpeta de instalacion, unos directorios hacia atras
# para encontrar tu SteamLibrary: steam -> configuración -> almacenamiento
# el path suele ser /home/usuario/.steam/steam o /mnt/disco/SteamLibrary

#incomplete example: */SteamLibrary/steamapps/common/wallpaper_engine/assets
ASSETS=""

#incomplete example: */SteamLibrary/steamapps/workshop/content/431960" <- id number on steam, same for everyone (i think)
WORKSHOP=""

#son los archivos de configuracion y recuperacion al encender del script, mover a discrecion
STATE_DIR="$HOME/.config/wallpaperengine"
STATE="$STATE_DIR/last_wallpaper.json"


