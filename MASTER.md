# GantzSpace — Proyecto de Dotfiles Personalizados

## 1. Base del proyecto

* Distribución: **CachyOS**
* Compositor: **Hyprland**
* Shell: **Fish**
* Base principal: **HakuSpace**
* Fork personal: **GantzSpace**
* GPU:

  * Intel UHD Graphics Comet Lake-H
  * NVIDIA GTX 1650 Mobile/Max-Q

El objetivo es convertir GantzSpace en una configuración personal basada en HakuSpace, incorporando únicamente las características de otros dotfiles que realmente aporten algo.

---

## 2. Filosofía

El proyecto debe ser:

* Modular
* Ligero
* Fluido
* Estable
* Fácil de mantener
* Fácil de personalizar

No quiero crear simplemente una mezcla de dotfiles.

La idea es:

```text
HakuSpace
    +
ideas seleccionadas de otros proyectos
    +
mis propias modificaciones
    =
GantzSpace
```

No se deben copiar repositorios completos si solamente necesitamos una característica.

---

## 3. Decisiones importantes

### Compositor

**Hyprland es definitivo.**

No cambiar a:

* Niri
* Mango
* Sway
* otros compositores

### Quickshell

**No utilizar Quickshell como parte central del proyecto.**

Solo reconsiderarlo si en el futuro existe una razón excepcional y se decide explícitamente.

### HakuSpace

Conservar cuando sea posible:

* estructura Lua
* configuración de Hyprland
* reglas
* keybinds
* workspaces
* monitores
* comportamiento de ventanas
* colores dinámicos
* estructura de configuración de usuario

No reemplazar componentes que ya funcionen correctamente sin una razón concreta.

---

## 4. Fuentes de características

### HakuSpace

**Base principal**

Repositorio:

https://github.com/hakuimaku/hakuspace

---

### iNiR

Principal fuente para:

* GUI de configuración
* organización de ajustes
* personalización del sistema

Repositorio:

https://github.com/snowarch/iNiR

---

### Serpantinum

Principal fuente para:

* Lockscreen
* Selector de wallpapers
* Centro de control
* SwayNC
* integración de controles
* ideas de WLogout

---

### Noro18

Fuente para:

* Waybar
* Rofi
* estilos
* organización visual

Repositorio:

https://github.com/Noro18/linux-ricing-dotfiles

---

### Otros proyectos

Los demás rices previamente estudiados solamente se utilizarán como fuentes de ideas puntuales.

No son bases del proyecto.

---

## 5. Proyectos descartados

### Caelestia

Descartado después de probarlo.

Motivos principales:

* consumo en idle poco atractivo;
* características similares o inferiores a otras fuentes;
* no aporta suficiente valor para incorporarlo.

### Configuraciones basadas en Quickshell

No serán utilizadas como base.

---

## 6. Forma de trabajo

Trabajar siempre de forma incremental:

```text
estado estable
    ↓
estudiar componente
    ↓
hacer backup / commit
    ↓
modificar un componente
    ↓
probar
    ↓
corregir
    ↓
commit
    ↓
siguiente componente
```

No modificar múltiples componentes importantes simultáneamente.

---

## 7. Git

GantzSpace es el repositorio principal.

Antes de cambios importantes:

```fish
git status
git diff
```

Crear commits después de comprobar que los cambios funcionan.

Ejemplos:

```text
base-state
lockscreen
wallpaper-selector
swaync
waybar
rofi
settings-gui
color-system
cleanup
```

---

## 8. Configuración del usuario

Mantener una separación razonable entre:

```text
configuración base
        +
configuración personal
```

No crear estructuras nuevas solamente por estética.

Primero estudiar la estructura existente de HakuSpace y reutilizarla cuando sea adecuada.

---

## 9. Rendimiento

Prioridad:

```text
Estabilidad
    >
Compatibilidad
    >
Mantenibilidad
    >
Rendimiento
    >
Complejidad visual
```

Evitar:

* procesos innecesarios
* servicios innecesarios
* demonios permanentes
* dependencias pesadas sin justificación
* duplicación de herramientas
* frameworks utilizados únicamente por estética

---

## 10. Forma de trabajar conmigo

* Uso **Fish**, no Bash.
* Preferir instrucciones paso a paso.
* No dar grandes listas de comandos si solo necesitamos unos pocos.
* Explicar qué vamos a comprobar antes de dar comandos.
* No repetir soluciones ya probadas.
* No borrar configuraciones sin respaldo.
* No reinstalar cosas que ya funcionan.
* Si un cambio puede romper Hyprland, crear backup/commit primero.
* No asumir que una característica pertenece al componente que visualmente parece controlarla.

Flujo preferido:

```text
explicar
↓
comandos
↓
resultado
↓
análisis
↓
siguiente paso
```

---

## 11. Objetivo final

Crear un rice propio que conserve lo mejor de HakuSpace y combine únicamente las características seleccionadas de otros proyectos.

El resultado debe sentirse como:

**GantzSpace**

y no como:

**HakuSpace + varios dotfiles copiados encima.**
