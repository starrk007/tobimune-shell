# Tobimune Shell  Documento maestro

## Identidad

Tobimune Shell es el repositorio principal `tobimune-shell`, una configuracin personal para **CachyOS / Arch Linux** y **Hyprland**. El repositorio de assets y wallpapers es `tobimune-archive`.

La configuracin personal vive en `~/suzaku`, que reemplaza a `~/hakucfg`. El estado local se almacena en `~/.local/state/tobimune`.

## Principios

* Hyprland es el compositor nico y soportado.
* El sistema debe ser modular, ligero, estable y mantenible.
* Las configuraciones personales deben permanecer separadas de la base del proyecto.
* Cada cambio importante debe probarse y respaldarse antes de continuar.
* No se incorporan dependencias pesadas ni componentes duplicados sin una razn concreta.

## Instalacin y mantenimiento

```fish
git clone https://github.com/starrk007/tobimune-shell.git ~/tobimune-shell
cd ~/tobimune-shell
./install.sh
```

```fish
./update.sh
./doctor.sh
./rollback.sh
```

`install.sh` instala la base, `update.sh` sincroniza cambios, `doctor.sh` detecta problemas y `rollback.sh` restaura un backup.

## Componentes

* Hyprland: ventanas, reglas, keybindings, workspaces y monitores.
* Waybar: barra, mdulos, indicadores y estilos.
* Rofi: lanzador, mens de energa, aplicaciones y wallpapers.
* SwayNC: notificaciones y centro de control.
* Lockscreen: bloqueo e informacin del sistema.
* Motor de temas: colores derivados del wallpaper.
* Utilidades: capturas, grabacin, portapapeles, luz nocturna y energa.

## Flujo de trabajo

```text
estado estable
    
backup o commit
    
modificar un componente
    
probar en Hyprland
    
documentar
    
commit
```

La configuracin debe sentirse como **Tobimune Shell**, no como una coleccin de dotfiles sin integracin.

