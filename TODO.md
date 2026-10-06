# GantzSpace — TODO

Este archivo contiene las tareas actuales del proyecto.

Debe actualizarse conforme avancemos.

---

# Estado actual

* [x] Elegir HakuSpace como base
* [x] Crear fork privado GantzSpace
* [x] Instalar GantzSpace
* [x] Confirmar Hyprland
* [x] Confirmar estructura Lua
* [x] Decidir no utilizar Quickshell como base
* [x] Probar iNiR
* [x] Probar Caelestia
* [x] Probar Serpantinum
* [x] Identificar características interesantes de iNiR
* [x] Identificar características interesantes de Serpantinum
* [x] Identificar características interesantes de Noro18

---

# 1. Preparación

* [ ] Revisar estado actual de GantzSpace
* [ ] Confirmar que el fork está limpio
* [ ] Crear commit/estado base
* [ ] Revisar estructura actual de configuración
* [ ] Identificar configuraciones que ya funcionan correctamente
* [ ] Identificar componentes que no necesitan modificaciones

---

# 2. Diseño

* [ ] Definir estructura final de componentes
* [ ] Definir estructura de configuración de usuario
* [ ] Definir sistema de colores
* [ ] Definir comunicación entre componentes
* [ ] Definir qué scripts serán compartidos

---

# 3. Lockscreen

* [ ] Estudiar implementación actual de HakuSpace
* [ ] Estudiar lockscreen de Serpantinum
* [ ] Identificar diferencias
* [ ] Decidir qué características conservar
* [ ] Adaptar diseño
* [ ] Integrar información del sistema
* [ ] Integrar música
* [ ] Integrar notificaciones
* [ ] Probar consumo
* [ ] Crear commit

---

# 4. Wallpaper

* [ ] Estudiar selector actual de HakuSpace
* [ ] Estudiar selector de Serpantinum
* [ ] Analizar transición tipo acordeón
* [ ] Definir interfaz
* [ ] Buscar implementación ligera
* [ ] Evitar Quickshell
* [ ] Integrar extracción de colores
* [ ] Probar cambio de wallpaper
* [ ] Crear commit

---

# 5. SwayNC / Centro de control

* [ ] Revisar implementación actual
* [ ] Estudiar SwayNC de Serpantinum
* [ ] Identificar qué pertenece a SwayNC
* [ ] Identificar scripts adicionales
* [ ] Diseñar estructura final
* [ ] Integrar notificaciones
* [ ] Integrar controles rápidos
* [ ] Integrar energía
* [ ] Integrar WLogout
* [ ] Probar
* [ ] Crear commit

---

# 6. Waybar

* [ ] Revisar estructura actual de HakuSpace
* [ ] Estudiar Waybar de Noro18
* [ ] Estudiar otros estilos seleccionados
* [ ] Definir módulos comunes
* [ ] Definir estructura de estilos
* [ ] Crear estilos adicionales
* [ ] Revisar scripts
* [ ] Revisar CSS
* [ ] Probar selector de estilos
* [ ] Crear estilo propio
* [ ] Crear commit

---

# 7. Rofi

* [ ] Revisar Rofi actual de HakuSpace
* [ ] Estudiar Rofi de Noro18
* [ ] Revisar otras ideas previamente estudiadas
* [ ] Definir estructura final
* [ ] Revisar aplicaciones
* [ ] Revisar configuración
* [ ] Revisar power menu
* [ ] Revisar wallpaper menu
* [ ] Revisar scripts
* [ ] Optimizar apariencia
* [ ] Crear commit

---

# 8. WLogout

* [ ] Revisar WLogout actual
* [ ] Revisar integración con SwayNC
* [ ] Comparar con Serpantinum
* [ ] Definir apariencia
* [ ] Integrar acciones
* [ ] Probar
* [ ] Crear commit

---

# 9. GUI de configuración

## Base

* [ ] Elegir tecnología
* [ ] Diseñar estructura
* [ ] Definir configuración central
* [ ] Definir comunicación con archivos Lua
* [ ] Crear primera ventana
* [ ] Crear navegación

## General

* [ ] Wallpaper
* [ ] Fecha
* [ ] Idioma
* [ ] Atajos

## Apariencia

* [ ] Colores
* [ ] Tema
* [ ] Modo oscuro/claro
* [ ] Color de acento
* [ ] Fuentes
* [ ] Iconos
* [ ] Bordes
* [ ] Blur
* [ ] Sombras

## Waybar

* [ ] Estilos
* [ ] Módulos
* [ ] Forma
* [ ] Muesca
* [ ] Interactividad

## Escritorio

* [ ] Widgets
* [ ] Wallpaper
* [ ] Galería
* [ ] Menú contextual

## Ventanas

* [ ] Gaps
* [ ] Bordes
* [ ] Forma
* [ ] Animaciones

## Pantallas

* [ ] Monitores
* [ ] Disposición
* [ ] Resolución
* [ ] Luz nocturna

## Periféricos

* [ ] Teclado
* [ ] Mouse
* [ ] Touchpad

## Batería

* [ ] Avisos
* [ ] Límite de carga
* [ ] Batería baja
* [ ] Batería crítica

## Lockscreen

* [ ] Reloj
* [ ] Tiempo de activación
* [ ] Música
* [ ] Usuario
* [ ] Avatar
* [ ] Elementos visibles

## Sistema

* [ ] Autostart
* [ ] Servicios
* [ ] Herramientas
* [ ] Temas
* [ ] Opciones avanzadas

---

# 10. Integración

* [ ] Integrar colores dinámicos
* [ ] Integrar wallpaper → colores
* [ ] Integrar colores → Waybar
* [ ] Integrar colores → Rofi
* [ ] Integrar colores → SwayNC
* [ ] Integrar colores → Lockscreen
* [ ] Revisar scripts compartidos
* [ ] Eliminar duplicación

---

# 11. Optimización

* [ ] Revisar procesos de autostart
* [ ] Revisar servicios
* [ ] Revisar demonios
* [ ] Revisar dependencias
* [ ] Revisar consumo en idle
* [ ] Eliminar herramientas redundantes
* [ ] Revisar tiempos de inicio
* [ ] Revisar comportamiento al suspender
* [ ] Revisar comportamiento al reiniciar

---

# 12. Limpieza

* [ ] Eliminar configuraciones de pruebas
* [ ] Eliminar dependencias innecesarias
* [ ] Revisar paquetes instalados
* [ ] Revisar archivos `.desktop`
* [ ] Crear respaldo final
* [ ] Revisar configuración del usuario
* [ ] Revisar estructura del repositorio

---

# 13. Posible reinstalación de CachyOS

Solo si al final se considera necesario.

* [ ] Crear backup completo
* [ ] Guardar lista de paquetes
* [ ] Guardar paquetes explícitos
* [ ] Guardar paquetes AUR
* [ ] Guardar `.desktop`
* [ ] Guardar configuraciones importantes
* [ ] Reinstalar CachyOS
* [ ] Instalar dependencias necesarias
* [ ] Instalar GantzSpace
* [ ] Restaurar configuración
* [ ] Comprobar funcionamiento

---

# 14. Estado final esperado

```text
CachyOS
    ↓
Hyprland
    ↓
GantzSpace
    │
    ├── HakuSpace base
    ├── estructura Lua
    ├── colores dinámicos
    │
    ├── Waybar personalizado
    ├── Rofi personalizado
    ├── SwayNC / Centro de control
    ├── WLogout
    ├── Lockscreen
    ├── Wallpaper selector
    └── GUI de configuración
```

---

# 15. Regla de implementación

No avanzar a una nueva sección importante hasta que la anterior esté:

* funcionando;
* probada;
* documentada;
* y, cuando corresponda, respaldada mediante Git.

```text
Implementar
    ↓
Probar
    ↓
Corregir
    ↓
Confirmar
    ↓
Commit
    ↓
Continuar
```
