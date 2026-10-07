# Arquitectura de Tobimune Shell

Tobimune Shell es una configuracin de escritorio para **CachyOS / Arch Linux** y **Hyprland**. El proyecto no mantiene capas de compatibilidad para otras distribuciones ni compositores.

## Estructura del repositorio

```text
tobimune-shell/
 assets/                 # Assets del proyecto; los wallpapers viven en tobimune-archive
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

El repositorio de wallpapers y otros assets pesados es `tobimune-archive`.

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

