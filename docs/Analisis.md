# Informe de análisis de GantzSpace/HakuSpace

## Estado de la inspección

- El repositorio está limpio según `git status`.
- No se ejecutaron scripts de instalación, actualización, rollback ni diagnóstico.
- No se modificó, creó, eliminó, movió ni renombró ningún archivo.
- El repositorio contiene principalmente la base original de HakuSpace; la identidad GantzSpace aparece sobre todo en los documentos externos proporcionados.
- El archivo etiquetado como `FEATURES.md` no existe con ese nombre exacto; el archivo recibido es `Feature.md`.

---

# 1. Estructura general

## Árbol funcional

```text
gantzSpace/
├── assets/
│   └── browser/
├── docs/
│   ├── architecture.md
│   ├── management.md
│   ├── core/
│   ├── nixos.md
│   └── vietnamese/
├── nix/
│   ├── flake.nix
│   ├── flake.nix.example
│   ├── hakuspace-config.nix
│   └── myown/
├── scripts/
│   ├── variables.sh
│   └── functions.sh
├── src/
│   ├── core/
│   ├── home/
│   └── packages/
├── install.sh
├── update.sh
├── rollback.sh
├── doctor.sh
├── README.md
├── LICENSE
└── .gitignore
```

## `src/core/`

Es el núcleo ejecutable de HakuSpace. Contiene scripts que posteriormente se despliegan de forma plana en `~/.local/bin`.

Categorías:

- `app/`: miniaplicaciones y gestores visuales.
  - Taskbar.
  - Desktop icons.
  - Rounded screen.
  - Edge trigger.
  - Cava layer.
- `lib/`: bibliotecas compartidas.
  - Estado y generación de temas.
  - Colores de acento.
  - Recarga de configuración.
- `menu/`: HakuMenu y sus submenús.
- `sys/`: bloqueo, apagado, idle, polkit, bienvenida y salida.
- `theme/`: wallpapers, estilos, colores, temas Rofi y generación de archivos.
- `util/`: screenshots, grabación, clipboard, Waybar, navegador, configuración y utilidades varias.

La documentación funcional de esta capa está en `src/core/README.md`.

## `src/home/`

Funciona conceptualmente como una copia del `$HOME` del usuario.

Contiene:

- `src/home/.config/`
  - Hyprland.
  - Waybar.
  - Rofi.
  - SwayNC.
  - Kitty.
  - Fish.
  - Cava.
  - GTK.
  - btop.
  - fastfetch.
  - Thunar.
  - mpv.
  - configuraciones para Niri, Mango y Labwc.
- `src/home/.local/state/hakuspace/`
  - Archivos iniciales de estado y temas.
- `src/home/hakucfg/`
  - Configuración personal del usuario.
- `src/home/.themes/`
  - Tema Labwc.
- `.nanorc`.

## `src/packages/`

Listas de paquetes agrupadas por función:

- `pkg-core.txt`: componentes generales.
- `pkg-service.txt`: servicios y herramientas de sistema.
- `pkg-optional.txt`: herramientas opcionales.
- `pkg-hyprland.txt`.
- `pkg-niri.txt`.
- `pkg-mango.txt`.
- `pkg-labwc.txt`.

## `scripts/`

`variables.sh` define rutas, listas de paquetes, configuraciones excluidas y destinos.

`functions.sh` implementa:

- backups;
- copias;
- symlinks recursivos;
- detección del modo de despliegue;
- selección de compositor;
- despliegue de scripts;
- despliegue del repositorio de assets;
- inicialización de `~/hakucfg`;
- inicialización del estado de temas.

## `docs/`

La documentación más importante es:

- `docs/architecture.md`: arquitectura y flujo general.
- `docs/management.md`: sistema de symlinks/copia.
- `docs/core/lib.md`: estado y temas.
- `docs/core/theme.md`: motor visual.
- `docs/core/sys.md`: bloqueo, idle y apagado.
- `docs/core/util.md`: utilidades.
- `docs/core/menu.md`: HakuMenu.
- `docs/core/app.md`: miniaplicaciones.
- `docs/nixos.md`: integración NixOS.

## `assets/`

Contiene modificaciones de navegador:

- `newtab.html`.
- `userChrome.css`.

La documentación indica que estos assets no se copian automáticamente como parte del flujo normal de configuración.

## `nix/`

Contiene:

- Flake principal.
- Plantilla de flake.
- Módulo NixOS de HakuSpace.
- Configuraciones personales de ejemplo dentro de `myown/`.

Es una ruta alternativa de instalación y configuración para NixOS, no el camino principal para una instalación Arch/CachyOS.

## Scripts raíz

- `install.sh`: instalación inicial.
- `update.sh`: actualización del repositorio y despliegue.
- `rollback.sh`: restauración de backups.
- `doctor.sh`: diagnóstico de symlinks y estado.
- `README.md`: documentación de uso.

## Archivos generados o temporales

El repositorio contiene plantillas para archivos que se generan fuera del repositorio:

- `~/.local/state/hakuspace/state/state.env`.
- `~/.local/state/hakuspace/theme/*`.
- `~/.local/state/hakuspace/opaque/*`.
- `~/.cache/current_wallpaper`.
- previews de videos en `~/Videos/Wallpapers/.thumbnails`.
- archivos temporales de grabación en `/tmp`.
- estado temporal de wallpaper aleatorio en `/tmp/random_wallpaper_status`.
- backups en `~/.backup/Backup_<timestamp>`.

Los archivos de `src/home/.local/state/hakuspace/` son valores iniciales o defaults, no necesariamente el estado vivo del sistema.

---

# 2. Arquitectura real

## Punto de entrada de configuración

Para Hyprland, el punto de entrada es:

`hyprland.lua`

Ese archivo carga:

```lua
require("config/config")
require("config/autostart")
require("config/environment")
require("config/animation")
require("config/keybinding")
require("config/rule")
require("config/layout")
```

Después intenta cargar:

```lua
../../hakucfg/wm/hyprland-custom
```

Por tanto, el sistema está dividido en:

```text
Hyprland
  ↓
hyprland.lua
  ↓
config/*.lua
  ↓
~/hakucfg/wm/hyprland-custom.lua
```

No existe un `hyprland.conf` tradicional en el repositorio. El sistema usa la integración Lua de HakuSpace. La forma exacta en la que la instalación de Hyprland invoca `hyprland.lua` no está definida explícitamente dentro del repositorio; probablemente depende de la integración del entorno HakuSpace/NixOS o de la configuración externa del usuario. Esto queda como **no determinado por el código disponible**.

## Flujo de inicio de Hyprland

El flujo real que sí se puede determinar es:

```text
Hyprland
  ↓
hyprland.lua
  ↓
config/autostart.lua
  ↓
evento hyprland.start
  ├── dbus-update-activation-environment
  ├── systemctl --user import-environment
  ├── polkit_start.sh
  ├── swaync
  ├── wl-paste + cliphist
  ├── nm-applet
  ├── blueman-applet
  ├── hypridle
  ├── fcitx5
  ├── wallpaper_resume.sh
  ├── rounded_screen_manager.sh --startup
  ├── edge_trigger_manager.sh --startup
  ├── taskbar_manager.sh --startup
  ├── waybar_manager.sh
  ├── desktop_icons_manager.sh --startup
  └── welcome.sh
```

La fuente es `autostart.lua`.

## Mapa principal

```text
install.sh
  ↓
scripts/functions.sh
  ├── instala paquetes
  ├── crea backups
  ├── despliega src/home
  ├── despliega src/core
  ├── crea ~/hakucfg
  ├── inicializa ~/.local/state/hakuspace
  └── opcionalmente clona hakuspace-archive

Hyprland
  ↓
~/.config/hypr/hyprland.lua
  ↓
config/*.lua
  ├── configuración general
  ├── autostart
  ├── variables de entorno
  ├── keybindings
  ├── reglas
  ├── layouts
  └── configuración del usuario en ~/hakucfg

autostart
  ↓
waybar_manager.sh
  ↓
~/.config/waybar/config → modo seleccionado
~/.config/waybar/style.css → modo seleccionado

wallpaper_select.sh
  ↓
wallpaper_set.sh
  ↓
awww o mpvpaper
  ↓
get_accent_color.py
  ↓
gen_style.sh
  ↓
~/.local/state/hakuspace/theme/*
  ↓
apply_style.sh
  ├── SwayNC
  ├── Kitty
  ├── GTK
  ├── Waybar indirectamente
  ├── Hyprlock indirectamente
  └── otros componentes
```

---

# 3. Configuración de Hyprland

## `hyprland.lua`

`hyprland.lua` es el agregador principal.

Carga:

- configuración general;
- autostart;
- entorno;
- animaciones;
- keybindings;
- reglas;
- layout.

También intenta cargar la configuración personal:

```text
~/hakucfg/wm/hyprland-custom.lua
```

Si falla, envía una notificación mediante `notify-send`.

## Configuración general y monitores

`config.lua` controla:

- gaps internos y externos;
- tamaño de bordes;
- colores de bordes;
- transparencia;
- sombras;
- blur;
- redondeado;
- animaciones;
- input;
- touchpad;
- cursor;
- gestos;
- monitor por defecto.

El monitor está definido de forma genérica:

```text
output = ""
mode = preferred
position = auto
scale = 1
```

Esto significa que no existe una configuración específica para la pantalla Intel/NVIDIA dentro de este archivo.

## Variables de entorno

`environment.lua` define:

- `XDG_SESSION_TYPE`;
- `XDG_CURRENT_DESKTOP`;
- variables Wayland;
- variables GTK;
- variables Qt;
- integración Firefox;
- Java;
- SDL;
- Clutter;
- VA-API;
- Fcitx.

## Keybindings

`keybinding.lua` controla:

- abrir Kitty;
- abrir navegador;
- mostrar SwayNC;
- clipboard;
- selector de wallpaper;
- screenshots;
- Waybar;
- volumen;
- brillo;
- reproducción multimedia;
- workspaces;
- movimiento y redimensionado;
- reload de Hyprland;
- widgets Haku.

La mayoría de las acciones delegan la lógica a scripts en `~/.local/bin`.

Ejemplos:

```text
SUPER + Q
  → kitty

SUPER + B
  → open_browser.sh

SUPER + N
  → swaync-client

SUPER + Y
  → wallpaper_select.sh

SUPER + SHIFT + P
  → screenshot.sh --fullscreen

SUPER + CTRL + W
  → waybar_manager.sh --toggle
```

## Reglas

`rule.lua` controla:

- workspaces persistentes;
- VS Code en workspace especial;
- ventanas flotantes;
- ventanas XDG;
- opacidad;
- reglas de Rofi;
- reglas de Waybar;
- reglas de SwayNC;
- reglas de taskbar;
- desktop icons;
- widgets Haku;
- layouts de scrolling.

Hay un acoplamiento claro entre las reglas y nombres concretos:

```text
seycmd
seyclock
seylavat
seycava
taskbar.*
desktop-icons
rofi
waybar
swaync-control-center
```

## Layouts

`layout.lua` define opciones para:

- dwindle;
- master;
- scrolling.

El script `haku.sh` detecta el layout activo mediante Hyprland y organiza los widgets en consecuencia.

## Archivo de usuario

La filosofía declarada por HakuSpace es no modificar directamente los archivos base. La personalización se realiza en:

```text
~/hakucfg/wm/hyprland-custom.lua
```

Eso está reflejado en comentarios de los archivos Lua y en el `require` de `hyprland.lua`.

---

# 4. Componentes externos

## Waybar

Configuración:

```text
src/home/.config/waybar/
├── top/
├── left/
├── island/
├── neon/
├── coredge/
├── minimal/
├── legacy/
└── taskbar/
```

Cada modo contiene:

- `config`;
- `style.css`.

También existen módulos compartidos en `module/`.

Gestión:

`waybar_manager.sh`

Hace lo siguiente:

- selecciona el modo actual;
- crea symlinks internos:
  - `~/.config/waybar/config`;
  - `~/.config/waybar/style.css`;
- guarda el modo en `~/.local/state/hakuspace/state/waybar_current_mode`;
- conserva el estado encendido/apagado;
- reinicia Waybar;
- permite seleccionar modos con Rofi;
- permite modos definidos por el usuario en `~/hakucfg/config/waybar`.

Inicio:

```text
autostart.lua
  → waybar_manager.sh
  → waybar
```

Dependencias:

- Waybar;
- Rofi para selección;
- `notify-send`;
- estado HakuSpace;
- opcionalmente configuración personalizada.

Es un componente relativamente modular y reemplazable, aunque sus keybindings y reglas de Hyprland dependen de la namespace `waybar`.

## Rofi

Configuración:

- `config.rasi`;
- temas en `src/home/.config/rofi/themes/`;
- `wallpaper-select.rasi`;
- `shutdown.rasi`;
- `shutdown-vert.rasi`.

Se utiliza para:

- launcher;
- selector de wallpapers;
- selector de Waybar;
- cambio de tema;
- power menu;
- grabación;
- HakuMenu;
- selector de color;
- selector de fuentes.

Scripts principales:

- `hakumenu.sh`;
- `hm_general.sh`;
- `hm_setting.sh`;
- `hm_theme.sh`;
- `wallpaper_select.sh`;
- `change_theme.sh`;
- `rofi_theme_switcher.sh`.

Dependencias:

- Rofi;
- Kitty;
- ImageMagick en algunas funciones;
- scripts del sistema.

Está bastante extendido, pero sus temas pueden reemplazarse sin modificar la arquitectura central si se conservan las interfaces de los scripts.

## SwayNC

Configuración:

- `src/home/.config/swaync/config.json`;
- `src/home/.config/swaync/style.css`.

Inicio:

```text
autostart.lua
  → swaync
```

Control:

- `swaync-client`;
- keybindings;
- `apply_style.sh`;
- HakuMenu.

Hyprland aplica una regla de layer a la namespace:

```text
swaync-control-center
```

Dependencias:

- SwayNC;
- `notify-send`;
- estilos generados;
- posiblemente NetworkManager, audio y scripts auxiliares para controles.

Es reemplazable, pero los keybindings, estilos y la lógica de `apply_style.sh` tendrían que adaptarse.

## Hyprlock

Configuración:

- `hyprlock.conf`;
- `hyprlock_tiny.conf`;
- personalización en `~/hakucfg/config/hyprlock.conf`.

Inicio:

```text
hypridle
  → loginctl lock-session
  → lock.sh
  → hyprlock
```

`lock.sh` detecta resolución y decide entre la configuración normal y la tiny.

Los archivos de Hyprlock cargan:

```text
~/.local/state/hakuspace/theme/hyprland-style.conf
~/hakucfg/config/hyprlock.conf
```

Depende del motor de colores dinámicos.

## Hypridle

Configuración:

- `hypridle.conf`;
- personalización en `~/hakucfg/config/hypridle.conf`.

Inicio:

```text
autostart.lua
  → hypridle
```

Funciones:

- bajar brillo;
- bloquear sesión;
- apagar DPMS;
- reactivar DPMS;
- suspender el sistema.

Depende de:

- `brightnessctl`;
- `loginctl`;
- `systemctl`;
- `dpms_handler.sh`;
- `idle_inhibit.sh`;
- Hyprlock.

Es fundamental para la experiencia de sesión, pero puede reemplazarse por otro gestor de idle si se conserva el contrato de bloqueo y DPMS.

## Wallpapers estáticos y dinámicos

Configuración de usuario en `setting.sh`:

- `WALL_DIR`;
- `WALL_MPV_DIR`;
- intervalo;
- transición de AWWW;
- extracción de color;
- comando de grabación;
- modos de Waybar.

Selección:

`wallpaper_select.sh`

Permite:

- wallpapers de imagen;
- wallpapers de video;
- previews;
- selección mediante Rofi;
- cambio de acento tras seleccionar.

Aplicación:

`wallpaper_set.sh`

Utiliza:

- `awww` para imágenes;
- `mpvpaper` para videos;
- `wlr-randr` para detectar monitor;
- ImageMagick para generar caches;
- `file` para detectar MIME.

Persistencia:

- `~/.cache/current_wallpaper`.

Reanudación:

`wallpaper_resume.sh`

Se ejecuta desde `autostart.lua`.

El cambio automático está implementado por `random_wallpaper.sh`, pero no aparece iniciado directamente en `autostart.lua`. Su activación parece depender de HakuMenu u otra acción del usuario.

## Colores dinámicos

Flujo:

```text
wallpaper_set.sh
  ↓
get_accent_color.py
  ↓
gen_style.sh
  ↓
~/.local/state/hakuspace/state/state.env
~/.local/state/hakuspace/theme/*
  ↓
apply_style.sh
```

`gen_style.sh` genera:

- `colors.css`;
- `fonts.css`;
- `hyprland-style.conf`;
- `hyprland-style.lua`;
- `rofi-style.rasi`;
- `rofi-wallpaper-select.rasi`;
- `kitty-style.conf`;
- tema de btop;
- `newtab.css`;
- `niri-style.kdl`;
- `mangowm-style.conf`;
- posibles bloques Labwc.

`haku_theme.sh` define el estado canónico:

```text
~/.local/state/hakuspace/state/state.env
```

Los archivos renderizados no son la fuente de verdad.

## WLogout

No se encontró:

- configuración de WLogout;
- script específico de WLogout;
- archivo `.desktop`;
- paquete explícito para WLogout.

Por tanto, WLogout no parece formar parte actualmente de HakuSpace. La integración mencionada en `TODO.md` y `Feature.md` pertenece a la evolución futura deseada, no a la arquitectura actual.

## Terminal

La terminal principal es Kitty.

Configuración:

- `kitty.conf`;
- personalización en `~/hakucfg/config/kitty.conf`;
- tema generado en `~/.local/state/hakuspace/theme/kitty-style.conf`.

Se inicia mediante keybindings y también es utilizada por `haku.sh` para crear widgets.

## Audio

Se utilizan:

- `wpctl` para volumen;
- `playerctl` para multimedia;
- `pavucontrol` como GUI;
- `cava` para visualización;
- `pactl` y PipeWire/PulseAudio para grabación.

El audio está repartido entre:

- keybindings;
- Waybar;
- `cava`;
- `record.sh`;
- Haku widgets.

## Brillo

Se usa `brightnessctl` en:

- keybindings;
- Hypridle;
- notificaciones o scripts de sistema.

## Screenshots

`screenshot.sh` utiliza:

- `grim`;
- `slurp`;
- `wl-copy`;
- `notify-send`.

Se puede ejecutar en pantalla completa o por región.

## Screen recording

`record.sh` utiliza:

- `wl-screenrec`;
- `pactl`;
- PipeWire;
- Rofi;
- `notify-send`.

Puede grabar:

- solo audio del sistema;
- micrófono y audio del sistema;
- video sin sonido.

Mantiene archivos de estado en `/tmp`.

## Miniaplicaciones Haku

Incluyen:

- taskbar;
- desktop icons;
- rounded screen;
- edge trigger;
- Cava layer.

Cada una tiene:

- script Python o shell;
- manager;
- estado y configuración bajo `~/hakucfg` o `~/.local/state/hakuspace`.

Se inician desde `autostart.lua`, aunque algunos solo se activan si están habilitados en estado/configuración.

---

# 5. Instalador y scripts

## `install.sh`

Flujo:

```text
install.sh
  ↓
select_window_manager
  ↓
select_deploy_mode
  ↓
verifica Arch/pacman
  ↓
instala yay si falta
  ↓
instala git y curl
  ↓
instala listas de paquetes
  ↓
crea directorios
  ↓
opcionalmente configura NixOS
  ↓
hace backup
  ↓
despliega configs
  ↓
despliega scripts
  ↓
opcionalmente clona hakuspace-archive
  ↓
crea estado inicial
  ↓
genera tema inicial
  ↓
configura shell Fish
  ↓
configura ly
  ↓
configura tema GNOME
  ↓
establece Thunar como file manager
```

### Paquetes

Instala usando `yay`:

- el paquete específico del compositor;
- `pkg-core.txt`;
- `pkg-service.txt`;
- `pkg-optional.txt`.

El filtro de paquetes acepta solamente nombres con caracteres alfanuméricos y `@._+-`. Los comentarios se eliminan.

No usa un gestor genérico para otras distribuciones. Para sistemas no basados en Arch, el usuario debe instalar los paquetes manualmente.

### Backups

Los archivos existentes se mueven a:

```text
~/.backup/Backup_<timestamp>
```

No se realiza simplemente una copia: normalmente se mueven los destinos conflictivos antes del despliegue.

### Despliegue

El usuario elige entre:

```text
symlink
copy
```

En modo symlink:

- cada archivo de `src/home/.config` se enlaza individualmente;
- los scripts de `src/core` se enlazan individualmente;
- los directorios no se convierten necesariamente en un único symlink; se realiza symlinking profundo.

En modo copy:

- los archivos se copian;
- los scripts se copian;
- el repositorio deja de reflejar automáticamente las modificaciones realizadas en `$HOME`.

### Configuraciones de una sola instalación

`ONCE_CONFIGS` incluye:

- Thunar;
- xfce4;
- mpv;
- btop;
- cava;
- `mimeapps.list`.

Estas se copian y no se vuelven a sobreescribir normalmente en futuras actualizaciones.

### Configuraciones excluidas del despliegue general

`SKIP_CONFIGS` incluye:

- Hyprland;
- Niri;
- Mango;
- Labwc;
- GTK 3.

Estas se despliegan en pasos específicos.

### `~/hakucfg`

Se crea o completa mediante `check_control_dir`.

Archivos esperados:

- `setting.sh`;
- configuraciones personalizadas de Hyprland, Niri y Mango;
- `hypridle.conf`;
- `hyprlock.conf`;
- Kitty;
- Fish;
- taskbar;
- `general-menu.sh`;
- directorios de Waybar y Rofi.

La configuración personal del usuario se copia desde `src/home/hakucfg/`, pero después se mantiene fuera del repositorio principal.

### Assets externos

El instalador puede clonar:

```text
https://github.com/hakuimaku/hakuspace-archive.git
```

en:

```text
~/hakuspace-archive
```

Luego ejecuta su `setup.sh`.

Esto instala o copia assets que no existen en este repositorio principal, como wallpapers, iconos o temas.

## `update.sh`

Además de actualizar, modifica el propio repositorio local.

Flujo:

1. Copia temporalmente el script a `/tmp`.
2. Permite cambiar a `main` y hacer `git pull`.
3. Alternativamente busca el último tag.
4. Se reinicia si detecta que el script cambió.
5. Detecta modo symlink/copy.
6. Instala o actualiza paquetes core, service y del compositor.
7. Hace backup.
8. Actualiza configuraciones.
9. Evita sobrescribir `ONCE_CONFIGS`.
10. Actualiza scripts.
11. Puede reconstruir NixOS.
12. Inicializa estado.
13. Genera estilos si faltan.
14. Recarga Waybar.

No actualiza normalmente los contenidos personalizados de `~/hakucfg`.

## `rollback.sh`

Gestiona backups creados por HakuSpace.

Flujo:

1. Busca `~/.backup/Backup_*`.
2. Permite elegir uno.
3. Construye una lista de destinos administrados.
4. Mueve el estado actual a otro backup de seguridad.
5. Evita eliminar symlinks que no sean propios de HakuSpace.
6. Restaura archivos y symlinks.
7. Conserva configuraciones `ONCE_CONFIGS`.

Es más cuidadoso que un simple `cp -r`, especialmente al manejar symlinks.

## `doctor.sh`

Comprueba:

- symlinks rotos;
- symlinks reemplazados por archivos reales;
- destinos ausentes;
- directorios esperados;
- scripts en `~/.local/bin`;
- configuraciones de Hyprland;
- `~/hakucfg`;
- estado de HakuSpace.

En modo `copy`, omite la comprobación de integridad de symlinks.

---

# 6. Symlinks y ubicaciones externas

## Destinos principales

```text
$HOME/.config
$HOME/.local/bin
$HOME/.local/state/hakuspace
$HOME/.themes
$HOME/.nanorc
$HOME/hakucfg
$HOME/Pictures/Wallpapers
$HOME/Pictures/Screenshots
$HOME/Videos/Wallpapers
$HOME/.cache
$HOME/.backup
$HOME/hakuspace-archive
```

## Rutas absolutas importantes

El instalador modifica potencialmente:

```text
/etc/nixos/configuration.nix
/etc/nixos/flake.nix
/etc/nixos/hakuspace-config.nix
/etc/shells
```

También puede ejecutar:

```text
sudo nixos-rebuild switch
sudo systemctl enable ly@ttyX.service
sudo systemctl disable getty@ttyX.service
```

## Dependencia del nombre del repositorio

Hay referencias explícitas a:

```text
~/hakuspace
```

en `config.fish`.

Esto afecta:

- aliases `hsdoctor`;
- `hsupdate`;
- `hsrepo`.

También existen nombres internos `HAKU_DIR`, `HAKUSPACE_CUSTOM_DIR` y `hakuspace` en rutas de estado. Para convertirse en un proyecto independiente habría que separar cuidadosamente:

1. nombre del repositorio;
2. nombre de la carpeta instalada;
3. nombre del namespace de estado;
4. compatibilidad de scripts existentes.

## Symlinks internos

Además de los creados por el instalador, `waybar_manager.sh` crea:

```text
~/.config/waybar/config
~/.config/waybar/style.css
```

apuntando al modo activo.

---

# 7. Configuración del usuario frente a configuración interna

La separación ya existe y es uno de los puntos más valiosos de HakuSpace.

## Base interna

Está principalmente en:

- `src/home/.config`;
- `src/core`;
- `scripts`;
- listas de paquetes;
- reglas y defaults Lua.

Debe considerarse la base distribuida por el proyecto.

## Personalización del usuario

Está principalmente en:

```text
~/hakucfg
```

Ejemplos:

- `~/hakucfg/wm/hyprland-custom.lua`;
- `~/hakucfg/config/hyprlock.conf`;
- `~/hakucfg/config/hypridle.conf`;
- `~/hakucfg/config/kitty.conf`;
- `~/hakucfg/config/shell.fish`;
- `~/hakucfg/setting.sh`;
- `~/hakucfg/config/waybar`;
- `~/hakucfg/config/rofi`.

## Evaluación

La filosofía de separación está bien diseñada:

```text
base HakuSpace
  +
configuración personal en ~/hakucfg
```

Ventajas:

- las actualizaciones no deben sobrescribir todos los ajustes;
- el usuario puede extender Hyprland;
- los scripts leen variables centralizadas;
- Waybar y Rofi permiten overrides;
- Hyprlock e Hypridle tienen archivos personalizados.

Limitaciones:

- no toda la configuración está desacoplada;
- muchos scripts siguen usando directamente `~/.local/bin`;
- la configuración base contiene referencias fuertes al nombre HakuSpace;
- hay opciones que solo se pueden cambiar modificando archivos internos;
- la separación se basa en archivos y convenciones, no en un esquema validado.

---

# 8. Componentes que deberíamos conservar

## Fundamentales

### Sistema de despliegue

- symlinks profundos;
- modo copy;
- backups;
- rollback;
- doctor.

Es la infraestructura que permite mantener y recuperar el sistema.

### Arquitectura Lua de Hyprland

- `hyprland.lua`;
- archivos modulares;
- carga de configuración personalizada;
- reglas;
- layouts;
- keybindings;
- autostart.

Es uno de los elementos más valiosos de la base.

### Motor de temas

- estado canónico;
- generación de archivos;
- integración con wallpaper;
- render para múltiples componentes.

Está relativamente bien separado y es una buena base para GantzSpace.

### `~/hakucfg`

La separación de configuración personal debe conservarse, aunque posteriormente podría reorganizarse.

### HakuMenu y scripts de integración

HakuMenu funciona como una capa de control que conecta:

- Waybar;
- wallpapers;
- temas;
- SwayNC;
- energía;
- utilidades;
- miniaplicaciones.

Eliminarlo sin reemplazar sus funciones rompería muchos accesos.

## Componentes peligrosos de eliminar directamente

- `haku_theme.sh`;
- `gen_style.sh`;
- `apply_style.sh`;
- `wallpaper_set.sh`;
- `wallpaper_resume.sh`;
- `waybar_manager.sh`;
- `lock.sh`;
- `hypridle.conf`;
- `autostart.lua`;
- `keybinding.lua`;
- `functions.sh`;
- `variables.sh`.

## Componentes más independientes

- estilos CSS de Waybar;
- temas Rofi;
- apariencia SwayNC;
- Kitty;
- browser assets;
- tema btop;
- miniaplicaciones visuales individuales;
- presets de wallpaper.

---

# 9. Componentes candidatos a reemplazo

## Waybar

Tiene muchos presets y CSS, pero el gestor mantiene una interfaz simple:

```text
modo
  → config
  → style.css
```

Es un buen candidato para rediseño visual sin cambiar el resto.

Acoplamientos:

- keybindings;
- estado de Waybar;
- reglas de Hyprland;
- HakuMenu;
- scripts de módulos;
- temas dinámicos.

## Rofi

Es utilizado por muchos flujos. Se puede reemplazar visualmente con relativa facilidad, pero cambiarlo por otro launcher requeriría adaptar:

- HakuMenu;
- wallpaper selector;
- selección de Waybar;
- power menu;
- grabación;
- cambio de tema.

## SwayNC

Es reemplazable como daemon, pero no como simple archivo visual porque también participa en:

- autostart;
- reglas de Hyprland;
- `swaync-client`;
- actualización de estilos;
- centro de control futuro.

## Hyprlock

La configuración actual es relativamente autocontenida. Puede ser reemplazada por otra estética, pero hay que conservar:

- `lock.sh`;
- Hypridle;
- generación de colores;
- labels de `~/hakucfg`.

## Wallpaper selector

Tiene más acoplamiento de lo que parece:

```text
Rofi
  → wallpaper_select.sh
  → wallpaper_set.sh
  → awww/mpvpaper
  → color extraction
  → theme generation
  → reload
```

Se puede reemplazar la interfaz sin reemplazar el backend.

## Miniaplicaciones Haku

Son reemplazables individualmente, pero las reglas de Hyprland dependen de sus clases y namespaces:

- `seycmd`;
- `seyclock`;
- `seylavat`;
- `seycava`;
- `taskbar.*`;
- `desktop-icons`.

---

# 10. Riesgos detectados

## Dependencias ocultas

Varios scripts asumen programas que no siempre están declarados cerca de su uso:

- `notify-send`;
- `pactl`;
- `playerctl`;
- `fc-list`;
- `file`;
- `tac`;
- `pgrep`;
- `pkill`;
- `systemctl`;
- `loginctl`;
- `magick`;
- `awww`;
- `mpvpaper`;
- `wl-screenrec`.

Algunos aparecen en listas de paquetes; otros dependen del sistema base.

## Fuerte acoplamiento nominal

Hay muchas referencias a:

- HakuSpace;
- `hakuspace`;
- `~/hakuspace`;
- `~/.local/state/hakuspace`;
- `~/hakucfg`;
- nombres de clases `haku*`;
- nombres de scripts Haku.

Cambiar el nombre visible del proyecto no equivale a cambiar únicamente el README.

## Scripts con demasiadas responsabilidades

Especialmente:

- `install.sh`;
- `update.sh`;
- `functions.sh`;
- `gen_style.sh`;
- `wallpaper_select.sh`;
- `record.sh`.

Estos mezclan interacción, detección, despliegue, generación, compatibilidad y modificación del sistema.

## Actualización con efectos Git

`update.sh` puede:

- hacer checkout de `main`;
- hacer pull;
- cambiar a un tag;
- reiniciarse usando la nueva versión.

Eso es útil en el proyecto original, pero puede ser inconveniente para un proyecto propio donde se quiera controlar manualmente el estado Git.

## Diferencias entre modo copy y symlink

El sistema detecta heurísticamente el modo de despliegue. Un estado mixto puede producir:

- detecciones incorrectas;
- sobrescrituras;
- reparaciones inesperadas;
- diferencias entre configuraciones reales y fuente.

## Archivos generados como dependencia

Hyprland, Hyprlock, Kitty, GTK, Rofi y otros cargan archivos generados bajo:

```text
~/.local/state/hakuspace/theme
```

Si esos archivos faltan, algunos componentes usan defaults; otros pueden fallar visualmente.

## Estado distribuido

El estado está repartido entre:

- `~/.local/state/hakuspace`;
- `~/.cache`;
- `/tmp`;
- `~/hakucfg`;
- symlinks en `~/.config`;
- procesos en ejecución.

Esto complica backups completos y migraciones.

## Dependencia externa de `hakuspace-archive`

La instalación visual no está contenida completamente en este repositorio. Depende de otro repositorio externo y de su `setup.sh`.

Separar el proyecto requerirá decidir si:

- se conserva esa dependencia;
- se crea un archivo de assets propio;
- se convierte en dependencia opcional;
- se documentan versiones concretas.

## Posible defecto observado en `wallpaper_resume.sh`

El archivo contiene:

```bash
local is_mpvpaper = false
```

La sintaxis no corresponde a una asignación Bash estándar con `local`. Esto podría provocar que la variable no se inicialice como se espera y afectar la reanudación de wallpapers de video.

No se modificó porque el objetivo actual era únicamente analizar.

## WLogout no está implementado actualmente

El material de planificación menciona WLogout, pero no existe una implementación visible en el repositorio. No debe tratarse como un componente actual de HakuSpace.

## Soporte multi-compositor

La base mantiene configuraciones para:

- Hyprland;
- Niri;
- Mango;
- Labwc.

Eso aumenta:

- cantidad de paquetes;
- complejidad del instalador;
- lógica condicional;
- superficie de mantenimiento.

Para GantzSpace, Hyprland puede ser definitivo, pero eliminar soporte alternativo requerirá revisar cuidadosamente scripts compartidos.

---

# 11. Plan de separación de HakuSpace

## 1. Lo que conservaríamos prácticamente igual

- Arquitectura modular Lua.
- `hyprland.lua` como agregador.
- Separación entre base y `~/hakucfg`.
- Sistema de themes y estado canónico.
- Sistema de symlinks.
- Backups y rollback.
- Doctor.
- `waybar_manager.sh` como concepto.
- Flujo wallpaper → color → estilos.
- Configuración de Hyprland:
  - reglas;
  - keybindings;
  - layouts;
  - monitores;
  - autostart.
- Scripts de bloqueo e idle.
- HakuMenu si se conserva como interfaz de control.

## 2. Lo que adaptaríamos

- Nombre del repositorio.
- Nombre visible de la distribución.
- Rutas y aliases `~/hakuspace`.
- Variables `HAKU_DIR`, `HAKUSPACE_*`.
- Estado `~/.local/state/hakuspace`.
- Documentación.
- listas de paquetes;
- defaults de usuario;
- referencias de Fish.
- integración de assets.
- mensaje de instalación;
- nombres y branding de temas.
- configuración específica para CachyOS y hardware del usuario.

## 3. Lo que reemplazaríamos

Probablemente, de forma incremental:

- estilo de Waybar;
- temas Rofi;
- diseño de SwayNC;
- apariencia de Hyprlock;
- selector de wallpapers;
- HakuMenu;
- miniaplicaciones visuales que no encajen con la identidad propia;
- integración de colores si se desea otro modelo.

La sustitución debe preservar primero las interfaces funcionales:

```text
script → estado → configuración → componente
```

## 4. Lo que eliminaríamos

Después de verificar que no son necesarios:

- soporte Niri;
- soporte Mango;
- soporte Labwc;
- paquetes específicos de compositores alternativos;
- configuraciones duplicadas de otros WMs;
- assets de prueba;
- funcionalidades no utilizadas;
- referencias al flujo NixOS si no se va a mantener;
- widgets Haku que no se utilicen;
- dependencias opcionales sin uso real.

No conviene eliminarlos antes de obtener una lista completa de referencias.

## 5. Lo que crearíamos nosotros

- identidad GantzSpace;
- README propio;
- documentación arquitectónica propia;
- contrato de configuración del usuario;
- estructura de estados claramente definida;
- selector de wallpapers propio;
- GUI de configuración inspirada en iNiR;
- centro de control inspirado en Serpantinum;
- diseño propio de Waybar;
- diseño propio de Rofi;
- integración propia de SwayNC;
- configuración propia de Hyprlock;
- sistema de opciones centralizado;
- validación de configuración;
- tests o checks para scripts críticos;
- documentación explícita de dependencias.

## 6. Orden más seguro

### Fase 1: congelar la base

- Mantener el repositorio sin cambios.
- Crear un estado Git base.
- Documentar dependencias y rutas.
- Confirmar qué componentes están funcionando.

### Fase 2: establecer una capa de identidad

- Renombrar branding y documentación.
- No cambiar todavía la lógica interna.
- Mantener compatibilidad con rutas existentes.

### Fase 3: definir configuración personal

- Consolidar `~/hakucfg`.
- Documentar qué es base y qué es usuario.
- Evitar introducir una GUI antes de definir el modelo de configuración.

### Fase 4: aislar nombres y rutas

- Crear constantes o variables centrales.
- Reducir referencias directas a `hakuspace`.
- Cambiar estados y aliases de forma controlada.
- Mantener compatibilidad temporal si es necesario.

### Fase 5: mejorar un componente por vez

Orden recomendado:

```text
base Hyprland
  ↓
temas y colores
  ↓
wallpaper
  ↓
Waybar
  ↓
Rofi
  ↓
SwayNC
  ↓
Hyprlock
  ↓
GUI de configuración
  ↓
limpieza de componentes antiguos
```

### Fase 6: eliminar soporte no utilizado

Solo después de comprobar:

- referencias;
- paquetes;
- scripts;
- docs;
- reglas;
- instalador;
- rollback;
- doctor.

### Fase 7: consolidar

- actualizar documentación;
- revisar dependencias;
- probar instalación limpia;
- probar actualización;
- probar rollback;
- probar sesión Hyprland;
- crear commits por componente.

---

# Consideración sobre los tres documentos externos

Los documentos `MASTER.md`, `Feature.md` y `TODO.md` describen una dirección futura, no el estado actual del repositorio.

La diferencia principal es:

```text
Repositorio actual:
HakuSpace general, multi-WM, con Waybar/Rofi/SwayNC y scripts existentes.

Objetivo GantzSpace:
Hyprland como único compositor, configuración propia, GUI futura,
componentes visuales seleccionados y menor dependencia de HakuSpace.
```

En particular:

- iNiR aporta ideas futuras para una GUI, pero no hay GUI propia en este repositorio.
- Serpantinum aporta ideas futuras para lockscreen, wallpaper y centro de control, pero esas implementaciones no están presentes.
- Noro18 es una fuente futura para Waybar/Rofi, no una dependencia actual.
- WLogout aparece en la planificación, pero no en el código actual.
- Quickshell no aparece como dependencia actual y puede mantenerse fuera.

---

# Resumen ejecutivo

1. El repositorio sigue siendo esencialmente una base HakuSpace, no todavía un proyecto independiente plenamente convertido en GantzSpace.
2. La entrada principal de Hyprland es `hyprland.lua`, no `hyprland.conf`.
3. `hyprland.lua` carga módulos Lua para configuración, autostart, variables, keybindings, reglas y layouts.
4. La personalización de usuario se realiza principalmente mediante `~/hakucfg`.
5. El autostart inicia SwayNC, Hypridle, Waybar, clipboard, applets, wallpaper y miniaplicaciones.
6. Los scripts se despliegan de forma plana en `~/.local/bin`.
7. El sistema soporta symlinks profundos o copias.
8. El instalador crea backups antes de reemplazar configuraciones.
9. `update.sh` también puede modificar el checkout Git local.
10. `rollback.sh` y `doctor.sh` son componentes importantes para preservar la seguridad operativa.
11. Waybar se gestiona mediante modos intercambiables y symlinks internos.
12. Rofi es una dependencia transversal usada por casi todos los menús interactivos.
13. SwayNC está integrado con autostart, keybindings, reglas Hyprland y estilos dinámicos.
14. Hyprlock y Hypridle dependen de archivos personalizados en `~/hakucfg`.
15. El sistema de wallpapers conecta AWWW/mpvpaper con extracción de colores y generación de temas.
16. `~/.local/state/hakuspace` es el centro del estado generado.
17. El repositorio depende externamente de `hakuspace-archive` para parte de sus assets.
18. WLogout y una GUI de configuración propia todavía no existen en el código actual.
19. Hay referencias fuertes al nombre HakuSpace y a `~/hakuspace` que deberán aislarse antes de renombrar el proyecto.
20. La estrategia más segura es conservar primero la arquitectura Hyprland, temas, `~/hakucfg`, backups y despliegue, y reemplazar componentes visuales uno por uno.