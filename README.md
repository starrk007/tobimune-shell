# Tobimune Shell

Configuracin modular de escritorio optimizada exclusivamente para **CachyOS / Arch Linux** y **Hyprland**.

## Alcance

Tobimune Shell utiliza Hyprland como compositor nico. No incluye configuraciones, paquetes ni guas para otros compositores o distribuciones. La prioridad es ofrecer una base ligera, estable, mantenible y fcil de personalizar.

* **Repositorio principal:** `tobimune-shell`
* **Assets locales:** `assets/`
* **Configuracin personal:** `~/suzaku`
* **Estado local:** `~/.local/state/tobimune`

`~/suzaku` reemplaza a la antigua carpeta `~/hakucfg` y contiene variables, autostart y scripts personales que no deben sobrescribirse durante las actualizaciones.

## Instalacin

```fish
git clone https://github.com/starrk007/tobimune-shell.git ~/tobimune-shell
cd ~/tobimune-shell
./install.sh
```

Los scripts de mantenimiento son:

```fish
./update.sh
./doctor.sh
./rollback.sh
```

Antes de instalar, realiza una copia de seguridad de tus configuraciones actuales. El instalador despliega configuraciones de Hyprland, Waybar, Rofi, SwayNC y las utilidades del sistema segn el modo de despliegue seleccionado.

## Caractersticas principales

* Configuracin de Hyprland con reglas, keybindings, workspaces y monitores.
* Temas dinmicos derivados del wallpaper.
* Waybar, Rofi, SwayNC, lockscreen y selector de wallpapers integrados.
* Herramientas para capturas, grabacin, portapapeles, luz nocturna y energa.
* Despliegue mediante symlinks o copias, con backups y rollback.
* Diagnstico de symlinks y estado del despliegue mediante `doctor.sh`.

## Atajos principales

Los atajos se mantienen centrados en Hyprland y pueden personalizarse desde `~/suzaku`:

| Atajo | Accin |
| --- | --- |
| `SUPER + TAB` | Abrir el men de Tobimune Shell |
| `SUPER + L` | Bloquear la sesin |
| `SUPER + Q` | Cerrar la ventana activa |
| `SUPER + ENTER` | Abrir el terminal |
| `SUPER + 1..9` | Cambiar de workspace |

## Documentacin

* [Arquitectura](docs/architecture.md)
* [Gestin de dotfiles](docs/management.md)
* [Libreras principales](docs/core/lib.md)
* [Motor de temas](docs/core/theme.md)
* [Gestin del sistema](docs/core/sys.md)
* [Utilidades](docs/core/util.md)
* [Men](docs/core/menu.md)
* [Mini-aplicaciones](docs/core/app.md)
* [Caractersticas](FEATURES.md)
* [Tareas pendientes](TODO.md)

El proyecto est en desarrollo activo. Consulta los documentos antes de modificar componentes importantes y crea un commit estable despus de cada cambio verificable.
