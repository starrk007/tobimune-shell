# Arquitectura de Tobimune Shell

Tobimune Shell es una configuracin de escritorio para **CachyOS / Arch Linux** y **Hyprland**. El proyecto no mantiene capas de compatibilidad para otras distribuciones ni compositores.

## Estructura del repositorio

```text
tobimune-shell/
 assets/                 # Cursor y otros assets del proyecto
 docs/                   # Documentacin
 scripts/                # Funciones auxiliares
 install.sh              # Instalacin inicial
 update.sh               # Actualizacin
 rollback.sh             # Restauracin de backups
 doctor.sh               # Diagnstico
 src/
     core/               # Scripts desplegados en ~/.local/bin
     home/               # Base equivalente al directorio personal
        .config/        # Configuraciones de ~/.config
        .local/         # Configuracin local
        .themes/        # Temas
        suzaku/         # Plantillas para configuracin personal
     packages/           # Paquetes de CachyOS / Arch Linux
```

Los assets distribuidos por el instalador viven dentro de `assets/`.

## Despliegue

`src/home/` contiene la configuracin base. Durante la instalacin se puede elegir entre symlinks y copias:

* Symlink: los cambios en la configuracin desplegada se reflejan en el repositorio.
* Copy: los cambios permanecen en el sistema hasta que se copien manualmente al repositorio.

La configuracin personal se inicializa en `~/suzaku`. Esta carpeta reemplaza a `~/hakucfg` y nunca debe tratarse como una copia desechable de la base.

## Scripts del ciclo de vida

* `./install.sh`: crea backups, despliega la base e inicializa `~/suzaku`.
* `./update.sh`: sincroniza la base sin sobrescribir la configuracin personal.
* `./doctor.sh`: comprueba symlinks rotos y archivos reemplazados.
* `./rollback.sh`: restaura el estado anterior desde `~/.backup/`.

El estado propio de Tobimune Shell se guarda en `~/.local/state/tobimune`.

## Recorrido recomendado

1. [Gestin de dotfiles](management.md)
2. [Libreras principales](core/lib.md)
3. [Motor de temas](core/theme.md)
4. [Gestin del sistema](core/sys.md)
5. [Utilidades](core/util.md)
6. [Men](core/menu.md)
7. [Mini-aplicaciones](core/app.md)

## GUI de configuración

La configuración gráfica se implementa como una aplicación GTK/PyGObject
independiente. La GUI funciona como frontend y reutiliza los scripts existentes
en `~/.local/bin` para aplicar wallpapers, temas y acciones del sistema.
Rofi se conserva como lanzador de aplicaciones; las demás opciones se migrarán
progresivamente al GUI. El selector de wallpapers se abre como una ventana
independiente desde la sección General, en vez de ocupar el panel principal.
La ventana de configuración es flotante, centrada y fijada sobre las demás
aplicaciones mediante una regla de Hyprland. El taskbar no forma parte de esta
migración.
Se abre con `SUPER + COMMA` o ejecutando `~/.local/bin/tobimune-settings.sh`.

### Componentes y backend

En este proyecto, backend no significa necesariamente un servidor. Para las
funciones propias del sistema es el script o estado que ya controla Hyprland,
Waybar, SwayNC o el motor de temas. La GUI presenta ese estado y ejecuta la
operación existente. Por ejemplo, el selector de Waybar usa
`waybar_manager.sh` y el tema usa `gen_style.sh`.

Solo se necesita un backend nuevo cuando una característica no tiene todavía
un script, un archivo de estado o una interfaz de sistema reutilizable. En ese
caso se crea primero un componente pequeño y comprobable; la GUI no duplica la
lógica dentro de Python.
