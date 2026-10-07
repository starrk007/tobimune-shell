# Tobimune Shell  Caractersticas

Este documento contiene las caractersticas que se han identificado durante las pruebas de diferentes dotfiles.

No significa que todas deban implementarse.

Cada caracterstica debe evaluarse antes de incorporarse.

---

# 1. Tobimune Shell  Base

## Conservar

* Hyprland
* estructura Lua
* reglas de ventanas
* keybinds
* workspaces
* monitores
* configuracin de ventanas
* colores dinmicos
* estructura de configuracin de usuario
* componentes que ya funcionen correctamente

---

# 2. iNiR

## Caracterstica principal: GUI de configuracin

La idea que ms interesa rescatar de iNiR es disponer de una interfaz grfica desde la cual configurar el sistema.

No se busca copiar la implementacin completa.

## General

* Wallpaper
* Fecha
* Idioma
* Atajos de teclado

## Apariencia

* Colores
* Tema
* Modo oscuro/claro
* Color del sistema
* Color de acento
* Sombras
* Desenfoque
* Bordes
* Iconos
* Tamao de texto
* Fuente

## Aplicaciones

Posibilidad de modificar temas/colores de aplicaciones compatibles:

* Terminal
* VS Code
* Spotify / Spicetify
* Chrome
* Chromium

---

## Waybar

Posibles configuraciones:

* Diseo
* Forma
* Muesca
* Pginas
* Interactividad
* Conexiones
* Mdulos

---

## Escritorio

* Widgets
* Wallpapers aleatorios
* Wallpapers animados
* Wallpaper detrs de ventanas
* Galera
* Men del escritorio
* Acciones con clic derecho

---

## Ventanas

* Gaps
* Bordes
* Forma
* Animaciones

---

## Paneles laterales

Posible caracterstica futura.

No es prioridad.

---

## Centro de control

Configuracin de:

* SwayNC
* Controles rpidos
* Notificaciones
* Energa
* Volumen
* Conectividad
* No molestar

---

## Notificaciones

* Notificaciones
* No molestar
* Comportamiento
* Duracin
* Prioridades

---

## Sonido

* Volumen
* Sonidos de alerta
* Feedback
* Porcentajes

---

## Capturas y grabacin

* Capturas de pantalla
* Seleccin de regin
* Grabacin de pantalla

---

## Pantallas

* Monitores
* Disposicin
* Resolucin
* Monitor principal
* Luz nocturna
* Configuracin individual

---

## Teclado y mouse

* Teclado
* Mouse
* Touchpad
* Puntero
* Velocidad
* Comportamiento

---

## Batera

Especialmente para el porttil:

* Avisos
* Lmite de carga
* Batera baja
* Batera crtica
* Acciones automticas

---

## Lockscreen

Posibles configuraciones:

* Tiempo de activacin
* Reloj
* Informacin del usuario
* Avatar
* Msica
* Estado
* Actividad
* Clima
* Elementos visibles

---

## Visualizador de reproduccin

Posibles elementos:

* Cancin
* Artista
* Portada
* Progreso
* Controles
* Informacin de reproduccin

---

## Fuentes de informacin

Posibles fuentes:

* Clima
* Calendario
* Actualizaciones
* Sistema
* Batera
* Msica

Deben ser opcionales.

---

## Modo juego

Posible caracterstica futura.

No es prioridad actualmente.

---

## Ajustes avanzados

* Motor de wallpapers
* Widgets
* Monitores
* Autostart
* Servicios
* Herramientas
* Temas
* Sistema
* Configuracin avanzada

---

# 3. Serpantinum

## 3.1 Lockscreen

Caractersticas que interesan:

* Diseo general
* CPU
* RAM
* Temperatura
* Notificaciones
* Msica
* Informacin de reproduccin
* Organizacin visual
* Informacin del usuario

La meta es conseguir una experiencia similar sin copiar innecesariamente toda la configuracin.

---

## 3.2 Selector de wallpapers

Caractersticas que interesan:

* Navegacin visual
* Cambio sencillo de wallpaper
* Presentacin tipo acorden
* Varias opciones visibles
* Seleccin rpida
* Interfaz visual
* Integracin con colores dinmicos

La implementacin final puede utilizar otra herramienta.

No utilizar Quickshell solamente para conseguir esta interfaz.

---

## 3.3 Centro de control / SwayNC

Caractersticas que interesan:

* Mejor organizacin
* Notificaciones
* Controles rpidos
* Modos de energa
* Informacin del sistema
* Integracin con acciones de energa
* Integracin con WLogout
* Apariencia general

Antes de implementar se debe determinar qu parte corresponde realmente a SwayNC y qu parte corresponde a scripts u otros componentes.

---

# 4. Noro18

## Waybar

Investigar:

* Layout
* Mdulos
* Espaciado
* Iconos
* Indicadores
* Workspaces
* Reloj
* Tray
* Audio
* Red
* Batera
* Rendimiento
* Scripts
* Tooltips
* CSS

---

## Rofi

Investigar:

* Apariencia
* Tamao
* Navegacin
* Temas
* Integracin con scripts
* Mens
* Power menu
* Aplicaciones
* Configuracin

---

# 5. Otros rices estudiados

Pueden aportar:

* ideas visuales
* scripts
* mdulos
* pequeos componentes
* soluciones concretas

No deben convertirse en bases alternativas.

Si una caracterstica no aporta suficiente valor, se descarta.

---

# 6. Integracin deseada

## Sistema de colores

```text
Wallpaper
    
Extraccin de colores
    
Tema
    
Waybar
Rofi
SwayNC
Lockscreen
otros
```

---

## Configuracin

```text
GUI
 
configuracin central
 
componentes
```

La configuracin debe evitar que una misma opcin tenga que modificarse manualmente en varios archivos.

---

# 7. Caractersticas descartadas

## Caelestia

Descartado.

Motivos:

* consumo en idle;
* caractersticas similares o inferiores;
* poco valor adicional.

## Quickshell

No utilizar como base.

---

# 8. Prioridad aproximada

## Alta

* GUI de configuracin
* Lockscreen
* Wallpaper selector
* SwayNC / centro de control
* Waybar
* Rofi

## Media

* WLogout
* Integracin de colores
* Widgets
* Visualizador de reproduccin
* Configuracin avanzada

## Baja / futura

* Paneles laterales
* Fondos animados
* Modo juego
* Integraciones externas
* Fuentes adicionales

La prioridad puede cambiar durante el desarrollo.


