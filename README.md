# wallpaper-engine-picker

Una interfaz de terminal para [linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine) que te permite explorar y aplicar wallpapers de Wallpaper Engine desde la línea de comandos, con previews en vivo y soporte multi-monitor.

![selector](assets/monitor-selector.png)
![Wselector](assets/wallpaper-selector.png)

---

## Dependencias

- [Steam](https://store.steampowered.com/) con [Wallpaper Engine](https://store.steampowered.com/app/431960/Wallpaper_Engine/) instalado y al menos un wallpaper descargado
- [linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine) — seguí su README para instalarlo
- [`fzf`](https://github.com/junegunn/fzf) — buscador
- [`chafa`](https://hpjansson.org/chafa/) — previews de imágenes en terminal (se recomienda 1.10+ para soporte del protocolo de gráficos de Kitty)
- [`jq`](https://jqlang.github.io/jq/) — parseo de JSON
- `systemd` (sesión de usuario)

Instalar dependencias en Arch:
```bash
paru -S fzf chafa jq
```
En Ubuntu/Debian:
```bash
sudo apt install fzf chafa jq
```

---

## Instalación

1. Cloná el repositorio:
```bash
git clone https://github.com/CabraLoca69/Linux-WE-SimpleUi.git
cd Linux-WE-SimpleUi
```
2. Editá el archivo de configuración según tu setup (ver [Configuración](#configuración)):
```bash
$EDITOR ./config
```
⚠️ **Todos los scripts se niegan a correr hasta que hagas esto.** El config que
viene por defecto arranca con `DEFAULT=True` a propósito — correr con
`ASSETS`/`WORKSHOP` vacíos o un `MONITORS` de placeholder falla de formas
confusas y difíciles de debuggear más adelante (estado incorrecto del unit
de systemd, wallpapers que no se aplican silenciosamente, etc). Por eso los
scripts chequean este flag apenas cargan el config y salen inmediatamente
con un mensaje claro si sigue en `True`.

Una vez que configuraste `MONITORS`/`ASSETS`/`WORKSHOP` para tu máquina,
cambiá la primera línea del config a:

```bash
DEFAULT=False
```

3. Corré el instalador:
```bash
chmod +x ./install
./install
```

---

## Configuración

Toda la configuración vive en `~/.config/wallpaperengine/config`. Ambos scripts cargan este archivo automáticamente.

```bash
# ── Antes de nada ──────────────────────────────────────────────────────────
# Los scripts se niegan a correr mientras esto siga en True.
DEFAULT=True

# ── Monitores ──────────────────────────────────────────────────────────────
# Para encontrar los nombres de tus monitores: hyprctl monitors | grep Monitor
# O con: xrandr | grep " connected"
MONITORS=(
  "DP-1:Left"
  # "DP-3:Right"
  # "DP-2:Center"  # agregá o sacá monitores según necesites
)

# ── Wallpaper Engine ───────────────────────────────────────────────────────
# Ver: https://github.com/Almamu/linux-wallpaperengine/blob/main/README.md
# O corré: linux-wallpaperengine --help
FPS=30 
WE_ARGS=(--silent --disable-mouse)

# ── Rutas ──────────────────────────────────────────────────────────────────
# Usualmente unos directorios arriba de tu carpeta de instalación de wallpaper_engine:
# */SteamLibrary/steamapps/common/wallpaper_engine/assets
ASSETS=""
# */SteamLibrary/steamapps/workshop/content/431960
WORKSHOP=""

# Archivos de estado — donde el picker guarda el wallpaper actual para restaurarlo al bootear
STATE_DIR="$HOME/.config/wallpaperengine"
STATE="$STATE_DIR/last_wallpaper.json"
```

> **Tip:** Para encontrar la ruta de tu biblioteca de Steam, abrí Steam → Configuración → Almacenamiento.

Con un solo monitor configurado en `MONITORS`, las opciones de menú
multi-monitor (más abajo) no aparecen — elegir directamente ese único
monitor ya cubre ese caso.

---

## Uso

### Picker

```bash
wallpaper-picker
```

Abre un menú para:
- **Elegir un wallpaper distinto por monitor** — elegís un monitor, elegís un wallpaper para ese monitor
- **Mismo fondo en todos los monitores** — aplica el *mismo* wallpaper en cada monitor de forma independiente (cada monitor renderiza su propia instancia vía `--screen-root`; no es una sola imagen estirada)
- **Span (una sola imagen estirada)** — un *único* wallpaper estirado a lo largo de la geometría combinada de todos los monitores vía `--screen-span` (solo aparece con más de un monitor configurado)
- Reiniciar el servicio de wallpaper
- Resetear un servicio systemd fallido (limpia un `wallpaperengine.service` trabado de una corrida anterior que crasheó — necesario antes de que `systemd-run` acepte iniciar uno nuevo bajo el mismo nombre de unit)

Mientras explorás wallpapers, se renderiza un preview en vivo en el panel
derecho usando `chafa`. Chafa detecta automáticamente las capacidades de tu
terminal y usa el mejor renderizado disponible — protocolo de gráficos de
Kitty, Sixel, o arte ANSI/Unicode — según lo que soporte tu terminal (Kitty,
WezTerm, foot, Konsole y otras renderizan imágenes reales; el resto cae al
arte ASCII/ANSI de siempre).

### Restaurar al iniciar sesión

Para restaurar tu último wallpaper automáticamente al iniciar sesión, agregá esto a tu configuración de Hyprland (o el equivalente de tu compositor):

```ini
exec-once = ~/.local/bin/wallpaper-on-start
```
o en configuraciones .lua:

```ini
hl.on("hyprland.start", function()
    hl.exec_cmd("wallpaper-on-start")
end)
```
---

## Cómo funciona

El picker guarda la selección actual de wallpaper en
`~/.config/wallpaperengine/last_wallpaper.json` y corre
`linux-wallpaperengine` como un servicio de usuario de systemd
(`wallpaperengine.service`, transitorio, creado vía `systemd-run`). Al
iniciar sesión, `wallpaper-on-start` lee ese archivo y restaura el
wallpaper.

Cada vez que se aplica un wallpaper, el picker detiene el servicio en
ejecución y limpia su estado fallido (`systemctl --user reset-failed`)
antes de iniciar uno nuevo — un unit transitorio que terminó con error
queda "cargado" bajo su nombre hasta que se limpia explícitamente, y
`systemd-run` se niega a reusar ese nombre de otra forma (`Unit
wallpaperengine.service was already loaded or has a fragment file`).

---

## Solución de problemas

**`linux-wallpaperengine` dice "At least one background ID must be specified"** — el archivo de estado (`last_wallpaper.json`) no tiene una entrada válida para el monitor que estás apuntando, o el id de wallpaper ahí no corresponde a una carpeta real bajo `$WORKSHOP`. Revisá:
```bash
cat ~/.config/wallpaperengine/last_wallpaper.json
ls "$WORKSHOP"   # confirmá si el id realmente existe
```

**`Failed to start transient service unit: ... already loaded or has a fragment file`** — una corrida anterior de `linux-wallpaperengine` crasheó y dejó `wallpaperengine.service` trabado en estado `failed`. El picker ya limpia esto automáticamente antes de aplicar un wallpaper nuevo; si estás llamando código cercano a `apply_wallpaper` directamente, corré:
```bash
systemctl --user reset-failed wallpaperengine.service
```

**El preview no muestra nada (queda en blanco) en una terminal que no es Kitty, pero antes andaba bien** — `chafa` detecta automáticamente qué protocolo de gráficos usar en base a variables de entorno de la terminal (`$TERM`, `$KITTY_WINDOW_ID`, etc). Si abrís una terminal desde adentro de otra (por ejemplo, abrir Alacritty desde una sesión de Kitty), esas variables pueden quedar heredadas por la terminal hija aunque esta no soporte realmente el protocolo de gráficos de Kitty — chafa entonces intenta dibujar una imagen en formato Kitty que la terminal no puede renderizar, y el panel de preview queda en blanco. Verificá con:
```bash
echo "KITTY_WINDOW_ID=[$KITTY_WINDOW_ID] TERM=$TERM"
```
en la terminal afectada. Si no está vacío y en realidad no es Kitty, desactivalo antes de abrir el picker (`unset KITTY_WINDOW_ID`), o abrí tu terminal de cero en vez de anidarla dentro de otra.

**No pasa nada, los scripts salen inmediatamente con un mensaje sobre `DEFAULT`** — todavía no editaste `~/.config/wallpaperengine/config`. Ver [Instalación](#instalación).

---

## Créditos

- [linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine) por Almamu — sin esto nada de esto funciona
- [Wallpaper Engine](https://store.steampowered.com/app/431960/Wallpaper_Engine/) por Kristjan Skutta

---

## Licencia

MIT