# Gestin de dotfiles

Tobimune Shell despliega una base de configuracin para CachyOS / Arch Linux y Hyprland mediante symlinks o copias. La configuracin personal se mantiene separada en `~/suzaku`, reemplazo de la antigua carpeta `~/hakucfg`.

## Mapa de despliegue

```text
Repositorio                 Sistema
-----------                 -------
src/home/.config/*   ---->  ~/.config/*
src/core/*           ---->  ~/.local/bin/*
src/home/suzaku/*    -copy> ~/suzaku/*
```

El estado local del sistema se guarda en `~/.local/state/tobimune`.

## Modos

### Symlink (recomendado)

Los archivos se enlazan individualmente dentro de carpetas reales. Los cambios se sincronizan de inmediato y los caches o estados de las aplicaciones no contaminan el repositorio.

### Copy

Los archivos se copian al directorio personal. Es un modo sencillo y aislado, pero los cambios locales deben copiarse manualmente al repositorio.

`update.sh` detecta el modo existente y conserva ese comportamiento en las actualizaciones.

## Configuracin personal

`~/suzaku` contiene variables, autostart, keybindings personales y scripts propios. Los archivos faltantes se inicializan desde las plantillas, pero los archivos existentes no se sobrescriben. Esta carpeta es el reemplazo oficial de `~/hakucfg`.

## Scripts

```fish
./install.sh
./update.sh
./rollback.sh
```

* `install.sh` realiza el backup inicial y despliega la base.
* `update.sh` sincroniza configuraciones y scripts.
* `doctor.sh` informa de symlinks rotos o archivos reemplazados.
* `bash doctor.sh --runtime` realiza una comprobación de solo lectura de dependencias, sintaxis, Hyprland, Rofi, Waybar y SwayNC.
* `rollback.sh` elimina enlaces gestionados de forma segura y restaura un backup.

Los backups se almacenan en `~/.backup/Backup_<timestamp>`.
