# GantzSpace — Características

Este documento contiene las características que se han identificado durante las pruebas de diferentes dotfiles.

No significa que todas deban implementarse.

Cada característica debe evaluarse antes de incorporarse.

---

# 1. HakuSpace — Base

## Conservar

* Hyprland
* estructura Lua
* reglas de ventanas
* keybinds
* workspaces
* monitores
* configuración de ventanas
* colores dinámicos
* estructura de configuración de usuario
* componentes que ya funcionen correctamente

---

# 2. iNiR

## Característica principal: GUI de configuración

La idea que más interesa rescatar de iNiR es disponer de una interfaz gráfica desde la cual configurar el sistema.

No se busca copiar la implementación completa.

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
* Tamaño de texto
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

* Diseño
* Forma
* Muesca
* Páginas
* Interactividad
* Conexiones
* Módulos

---

## Escritorio

* Widgets
* Wallpapers aleatorios
* Wallpapers animados
* Wallpaper detrás de ventanas
* Galería
* Menú del escritorio
* Acciones con clic derecho

---

## Ventanas

* Gaps
* Bordes
* Forma
* Animaciones

---

## Paneles laterales

Posible característica futura.

No es prioridad.

---

## Centro de control

Configuración de:

* SwayNC
* Controles rápidos
* Notificaciones
* Energía
* Volumen
* Conectividad
* No molestar

---

## Notificaciones

* Notificaciones
* No molestar
* Comportamiento
* Duración
* Prioridades

---

## Sonido

* Volumen
* Sonidos de alerta
* Feedback
* Porcentajes

---

## Capturas y grabación

* Capturas de pantalla
* Selección de región
* Grabación de pantalla

---

## Pantallas

* Monitores
* Disposición
* Resolución
* Monitor principal
* Luz nocturna
* Configuración individual

---

## Teclado y mouse

* Teclado
* Mouse
* Touchpad
* Puntero
* Velocidad
* Comportamiento

---

## Batería

Especialmente para el portátil:

* Avisos
* Límite de carga
* Batería baja
* Batería crítica
* Acciones automáticas

---

## Lockscreen

Posibles configuraciones:

* Tiempo de activación
* Reloj
* Información del usuario
* Avatar
* Música
* Estado
* Actividad
* Clima
* Elementos visibles

---

## Visualizador de reproducción

Posibles elementos:

* Canción
* Artista
* Portada
* Progreso
* Controles
* Información de reproducción

---

## Fuentes de información

Posibles fuentes:

* Clima
* Calendario
* Actualizaciones
* Sistema
* Batería
* Música

Deben ser opcionales.

---

## Modo juego

Posible característica futura.

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
* Configuración avanzada

---

# 3. Serpantinum

## 3.1 Lockscreen

Características que interesan:

* Diseño general
* CPU
* RAM
* Temperatura
* Notificaciones
* Música
* Información de reproducción
* Organización visual
* Información del usuario

La meta es conseguir una experiencia similar sin copiar innecesariamente toda la configuración.

---

## 3.2 Selector de wallpapers

Características que interesan:

* Navegación visual
* Cambio sencillo de wallpaper
* Presentación tipo acordeón
* Varias opciones visibles
* Selección rápida
* Interfaz visual
* Integración con colores dinámicos

La implementación final puede utilizar otra herramienta.

No utilizar Quickshell solamente para conseguir esta interfaz.

---

## 3.3 Centro de control / SwayNC

Características que interesan:

* Mejor organización
* Notificaciones
* Controles rápidos
* Modos de energía
* Información del sistema
* Integración con acciones de energía
* Integración con WLogout
* Apariencia general

Antes de implementar se debe determinar qué parte corresponde realmente a SwayNC y qué parte corresponde a scripts u otros componentes.

---

# 4. Noro18

## Waybar

Investigar:

* Layout
* Módulos
* Espaciado
* Iconos
* Indicadores
* Workspaces
* Reloj
* Tray
* Audio
* Red
* Batería
* Rendimiento
* Scripts
* Tooltips
* CSS

---

## Rofi

Investigar:

* Apariencia
* Tamaño
* Navegación
* Temas
* Integración con scripts
* Menús
* Power menu
* Aplicaciones
* Configuración

---

# 5. Otros rices estudiados

Pueden aportar:

* ideas visuales
* scripts
* módulos
* pequeños componentes
* soluciones concretas

No deben convertirse en bases alternativas.

Si una característica no aporta suficiente valor, se descarta.

---

# 6. Integración deseada

## Sistema de colores

```text
Wallpaper
    ↓
Extracción de colores
    ↓
Tema
    ↓
Waybar
Rofi
SwayNC
Lockscreen
otros
```

---

## Configuración

```text
GUI
 ↓
configuración central
 ↓
componentes
```

La configuración debe evitar que una misma opción tenga que modificarse manualmente en varios archivos.

---

# 7. Características descartadas

## Caelestia

Descartado.

Motivos:

* consumo en idle;
* características similares o inferiores;
* poco valor adicional.

## Quickshell

No utilizar como base.

---

# 8. Prioridad aproximada

## Alta

* GUI de configuración
* Lockscreen
* Wallpaper selector
* SwayNC / centro de control
* Waybar
* Rofi

## Media

* WLogout
* Integración de colores
* Widgets
* Visualizador de reproducción
* Configuración avanzada

## Baja / futura

* Paneles laterales
* Fondos animados
* Modo juego
* Integraciones externas
* Fuentes adicionales

La prioridad puede cambiar durante el desarrollo.
