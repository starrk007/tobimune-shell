#!/usr/bin/env python3

"""Tobimune Shell settings GUI.

The GUI is intentionally a thin frontend. Existing shell scripts remain the
source of truth for applying wallpapers, themes, and system actions.
"""

from __future__ import annotations

import os
import re
import shlex
import subprocess
import sys
from pathlib import Path
from typing import Callable

import gi

gi.require_version("Gdk", "3.0")
gi.require_version("Gtk", "3.0")
gi.require_version("GdkPixbuf", "2.0")
from gi.repository import Gdk, GdkPixbuf, GLib, Gtk


STATE_FILE = Path.home() / ".local/state/tobimune/state/state.env"
LOCAL_BIN = Path.home() / ".local/bin"
WALLPAPER_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif", ".webp"}


def state_value(name: str, default: str) -> str:
    if not STATE_FILE.is_file():
        return default
    pattern = re.compile(rf"^{re.escape(name)}=(.*)$")
    for line in STATE_FILE.read_text(encoding="utf-8").splitlines():
        match = pattern.match(line)
        if match:
            value = match.group(1).strip()
            try:
                parsed = shlex.split(value, posix=True)
                if len(parsed) == 1:
                    return parsed[0]
            except ValueError:
                pass
            return value
    return default


def state_file_value(name: str, default: str) -> str:
    path = STATE_FILE.parent / name
    try:
        return path.read_text(encoding="utf-8").strip() or default
    except OSError:
        return default


def setting_value(name: str, default: Path) -> Path:
    settings_file = Path.home() / "suzaku/setting.sh"
    if not settings_file.is_file():
        return default
    pattern = re.compile(rf'^{re.escape(name)}="([^"]+)"$')
    for line in settings_file.read_text(encoding="utf-8").splitlines():
        match = pattern.match(line.strip())
        if match:
            return Path(os.path.expandvars(os.path.expanduser(match.group(1))))
    return default


class TobimuneGui(Gtk.Application):
    def __init__(self) -> None:
        super().__init__(application_id="org.tobimune.ShellSettings")
        self.window: Gtk.ApplicationWindow | None = None
        self.content: Gtk.Stack | None = None
        self.status_label: Gtk.Label | None = None

    def do_activate(self) -> None:
        if self.window is None:
            self.window = self.build_window()
        self.window.present()

    def build_window(self) -> Gtk.ApplicationWindow:
        window = Gtk.ApplicationWindow(application=self)
        window.set_title("Tobimune Shell · Configuración")
        window.set_default_size(980, 680)
        window.set_position(Gtk.WindowPosition.CENTER)
        window.set_resizable(True)
        window.set_decorated(True)
        window.connect("key-press-event", self.on_key_press)

        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        root.get_style_context().add_class("tobimune-root")
        window.add(root)

        topbar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        topbar.get_style_context().add_class("topbar")
        topbar.set_margin_top(14)
        topbar.set_margin_start(20)
        topbar.set_margin_end(20)
        topbar.set_margin_bottom(12)
        brand = Gtk.Label(label="TOBIMUNE  /  SETTINGS")
        brand.set_xalign(0)
        brand.get_style_context().add_class("brand")
        topbar.pack_start(brand, True, True, 0)
        close_button = Gtk.Button(label="Cerrar")
        close_button.get_style_context().add_class("close-button")
        close_button.connect("clicked", self.close_window)
        topbar.pack_end(close_button, False, False, 0)
        root.pack_start(topbar, False, False, 0)

        body = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        root.pack_start(body, True, True, 0)

        sidebar = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        sidebar.set_size_request(238, -1)
        sidebar.set_margin_bottom(18)
        sidebar.set_margin_start(20)
        sidebar.set_margin_end(24)
        sidebar_scroll = Gtk.ScrolledWindow()
        sidebar_scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        sidebar_scroll.set_min_content_width(238)
        sidebar_scroll.set_min_content_height(0)
        sidebar_scroll.add(sidebar)
        body.pack_start(sidebar_scroll, False, False, 0)

        sidebar.pack_start(self.sidebar_group("SHELL"), False, False, 0)

        self.content = Gtk.Stack()
        self.content.set_transition_type(Gtk.StackTransitionType.CROSSFADE)
        content_scroll = Gtk.ScrolledWindow()
        content_scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        content_scroll.set_min_content_width(620)
        content_scroll.add(self.content)
        self.content.set_margin_bottom(18)
        self.content.set_margin_end(28)
        self.content.set_margin_start(0)
        body.pack_start(content_scroll, True, True, 0)

        pages: list[tuple[str, str, Callable[..., Gtk.Widget]]] = [
            ("general", "General", self.general_page),
            ("appearance", "Apariencia", self.appearance_page),
            ("waybar", "Waybar", self.waybar_page),
            ("desktop", "Escritorio", self.desktop_page),
            ("control-center", "Centro de control", self.control_center_page),
            ("screens", "Pantallas", self.screens_page),
            ("tools", "Herramientas", self.tools_page),
        ]
        groups = {
            "SHELL": {"general", "appearance"},
            "COMPONENTES": {"waybar", "desktop", "control-center", "screens"},
            "HERRAMIENTAS": {"tools"},
        }
        for page_id, label, builder in pages:
            if page_id in groups["COMPONENTES"] and not getattr(self, "_components_group", False):
                sidebar.pack_start(self.sidebar_group("COMPONENTES"), False, False, 0)
                self._components_group = True
            if page_id in groups["HERRAMIENTAS"] and not getattr(self, "_tools_group", False):
                sidebar.pack_start(self.sidebar_group("HERRAMIENTAS"), False, False, 0)
                self._tools_group = True
            button = Gtk.Button(label=label)
            button.set_relief(Gtk.ReliefStyle.NONE)
            button.set_halign(Gtk.Align.FILL)
            button.get_style_context().add_class("nav-button")
            button.connect("clicked", self.show_page, page_id)
            sidebar.pack_start(button, False, False, 0)
            page = builder()
            self.content.add_named(page, page_id)

        spacer = Gtk.Box()
        sidebar.pack_start(spacer, True, True, 0)
        self.status_label = Gtk.Label(label="Listo")
        self.status_label.set_xalign(0)
        self.status_label.set_line_wrap(True)
        self.status_label.get_style_context().add_class("status")
        sidebar.pack_start(self.status_label, False, False, 0)

        self.load_css()
        self.content.set_visible_child_name("general")
        window.show_all()
        return window

    def load_css(self) -> None:
        accent = state_value("ACCENT_COLOR", "#99c9d2")
        if not re.fullmatch(r"#[0-9a-fA-F]{6}", accent):
            accent = "#99c9d2"
        accent_rgb = tuple(int(accent[index:index + 2], 16) for index in (1, 3, 5))
        accent_soft = f"rgba({accent_rgb[0]}, {accent_rgb[1]}, {accent_rgb[2]}, 0.16)"
        css = Gtk.CssProvider()
        css.load_from_data(f"""
            window, .tobimune-root {{
                background-color: #000000;
                color: #e7e2e7;
            }}
            .topbar {{
                background-color: rgba(0, 0, 0, 0.90);
                border-bottom: 1px solid rgba(255, 255, 255, 0.10);
            }}
            .brand {{
                color: {accent};
                font-size: 15px;
                font-weight: bold;
                letter-spacing: 1px;
            }}
            .page-title {{
                color: #e7e2e7;
                font-size: 28px;
                font-weight: bold;
            }}
            .section {{
                background-color: rgba(0, 0, 0, 0.72);
                border: 1px solid rgba(255, 255, 255, 0.14);
                border-radius: 18px;
                padding: 22px;
            }}
            .section-title {{
                color: {accent};
                font-size: 14px;
                font-weight: bold;
            }}
            .group-label {{
                color: rgba(231, 226, 231, 0.42);
                font-size: 10px;
                font-weight: bold;
                letter-spacing: 1px;
                padding: 16px 10px 5px 10px;
            }}
            .nav-button {{
                color: rgba(231, 226, 231, 0.70);
                background-color: transparent;
                border: 0;
                border-radius: 8px;
                padding: 10px 14px;
            }}
            .nav-button:hover, .nav-button:focus {{
                color: #e7e2e7;
                background-color: {accent_soft};
            }}
            .close-button {{
                color: rgba(231, 226, 231, 0.72);
                background-color: transparent;
                border: 1px solid rgba(255, 255, 255, 0.18);
                border-radius: 8px;
                padding: 5px 12px;
            }}
            .close-button:hover {{
                color: #000000;
                background-color: {accent};
            }}
            button {{
                background-color: rgba(255, 255, 255, 0.06);
                background-image: none;
                border: 1px solid rgba(255, 255, 255, 0.14);
                border-radius: 8px;
                box-shadow: none;
                color: #e7e2e7;
                padding: 8px 12px;
            }}
            button:hover {{
                background-color: {accent_soft};
                border-color: rgba(255, 255, 255, 0.28);
            }}
            button:active, button:checked {{
                background-color: rgba(255, 255, 255, 0.12);
            }}
            button label {{ color: inherit; }}
            button.suggested-action {{
                color: {accent};
                background-color: rgba(255, 255, 255, 0.06);
                border-color: {accent};
            }}
            button.suggested-action:hover {{
                color: #000000;
                background-color: {accent};
            }}
            entry, spinbutton {{
                background-color: rgba(0, 0, 0, 0.55);
                color: #e7e2e7;
                border: 1px solid rgba(255, 255, 255, 0.16);
                border-radius: 3px;
                padding: 5px 8px;
            }}
            .card {{
                background-color: rgba(255, 255, 255, 0.045);
                border: 1px solid rgba(255, 255, 255, 0.10);
                border-radius: 16px;
                padding: 14px;
            }}
            .card-title {{ color: #e7e2e7; font-weight: bold; }}
            .card-value {{ color: {accent}; font-size: 18px; font-weight: bold; }}
            switch {{
                background-color: rgba(255, 255, 255, 0.12);
                border-radius: 999px;
            }}
            switch:checked {{ background-color: {accent}; }}
            switch slider {{ border-radius: 999px; }}
            .muted, .subtitle, .status {{ color: rgba(231, 226, 231, 0.52); }}
        """.encode())
        Gtk.StyleContext.add_provider_for_screen(
            self.window.get_screen() if self.window else Gdk.Screen.get_default(),
            css,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

    def show_page(self, _button: Gtk.Button, page_id: str) -> None:
        if self.content is not None:
            self.content.set_visible_child_name(page_id)

    def sidebar_group(self, title: str) -> Gtk.Label:
        label = Gtk.Label(label=title)
        label.set_xalign(0)
        label.get_style_context().add_class("group-label")
        return label

    def on_key_press(self, _window: Gtk.ApplicationWindow, event: Gdk.EventKey) -> bool:
        if event.keyval == Gdk.KEY_Escape or (
            event.keyval == Gdk.KEY_w and event.state & Gdk.ModifierType.CONTROL_MASK
        ):
            self.close_window()
            return True
        return False

    def close_window(self, _button: Gtk.Button | None = None) -> None:
        self.quit()

    def page(self, title: str) -> Gtk.Box:
        page = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=16)
        page.set_margin_top(22)
        page.set_margin_start(4)
        page.set_margin_end(4)
        heading = Gtk.Label(label=title)
        heading.set_xalign(0)
        heading.get_style_context().add_class("page-title")
        page.pack_start(heading, False, False, 0)
        return page

    def hero(self, title: str, text: str) -> Gtk.Box:
        frame = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=7)
        frame.pack_start(box, False, False, 0)
        box.pack_start(self.description(text), False, False, 0)
        return frame

    def action_card(
        self,
        title: str,
        text: str,
        label: str,
        callback: Callable[[Gtk.Button], None],
    ) -> Gtk.Frame:
        frame = Gtk.Frame()
        frame.get_style_context().add_class("card")
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=9)
        frame.add(box)
        heading = Gtk.Label(label=title)
        heading.set_xalign(0)
        heading.get_style_context().add_class("card-title")
        box.pack_start(heading, False, False, 0)
        box.pack_start(self.description(text), False, False, 0)
        button = Gtk.Button(label=label)
        button.connect("clicked", callback)
        box.pack_start(button, False, False, 0)
        return frame

    def value_label(self, value: str, style: str) -> Gtk.Label:
        label = Gtk.Label(label=value)
        label.set_xalign(0)
        label.get_style_context().add_class("card-value")
        label.get_style_context().add_class(style)
        return label

    def show_appearance(self, _button: Gtk.Button) -> None:
        self.show_page(_button, "appearance")

    def apply_waybar_mode(self, _button: Gtk.Button, mode: str) -> None:
        self.run_script(_button, "waybar_manager.sh", "--set", mode)

    def section(self, title: str) -> tuple[Gtk.Frame, Gtk.Box]:
        frame = Gtk.Frame()
        frame.get_style_context().add_class("section")
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        frame.add(box)
        label = Gtk.Label(label=title)
        label.set_xalign(0)
        label.get_style_context().add_class("section-title")
        box.pack_start(label, False, False, 0)
        return frame, box

    def description(self, text: str) -> Gtk.Label:
        label = Gtk.Label(label=text)
        label.set_xalign(0)
        label.set_line_wrap(True)
        label.get_style_context().add_class("muted")
        return label

    def row(self, label: str, widget: Gtk.Widget) -> Gtk.Box:
        row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        text = Gtk.Label(label=label)
        text.set_xalign(0)
        row.pack_start(text, True, True, 0)
        row.pack_end(widget, False, False, 0)
        return row

    def general_page(self) -> Gtk.Widget:
        page = self.page("General")
        page.pack_start(self.hero(
            "",
            "Los cambios se aplican usando el mismo estado y scripts "
            "que ya utilizan Waybar, Rofi y SwayNC."
        ), False, False, 0)
        grid = Gtk.Grid()
        grid.set_column_spacing(12)
        grid.set_row_spacing(12)
        grid.attach(self.action_card(
            "Wallpaper", "Galería visual y cambio de fondo",
            "Abrir selector", self.open_wallpaper_dialog
        ), 0, 0, 1, 1)
        grid.attach(self.action_card(
            "Tema", "Color dinámico y estilo compartido",
            "Ir a Apariencia", self.show_appearance
        ), 1, 0, 1, 1)
        page.pack_start(grid, False, False, 0)
        return page

    def appearance_page(self) -> Gtk.Widget:
        page = self.page("Apariencia")
        page.pack_start(self.hero(
            "",
            "El tema compartido alimenta los estilos de Waybar, Rofi, "
            "SwayNC, Kitty y las aplicaciones integradas."
        ), False, False, 0)
        frame, box = self.section("Tema y shell")

        accent = Gtk.Entry()
        accent.set_text(state_value("ACCENT_COLOR", "#ffffff"))
        accent.set_width_chars(10)
        box.pack_start(self.row("Color de acento", accent), False, False, 0)

        font = Gtk.Entry()
        font.set_text(state_value("FONT_FAMILY", "monospace"))
        font.set_width_chars(22)
        box.pack_start(self.row("Fuente", font), False, False, 0)

        size = Gtk.SpinButton.new_with_range(8, 32, 1)
        size.set_value(float(state_value("FONT_SIZE", "14")))
        box.pack_start(self.row("Tamaño de fuente", size), False, False, 0)

        actions = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        apply_button = Gtk.Button(label="Aplicar apariencia")
        apply_button.get_style_context().add_class("suggested-action")
        apply_button.connect("clicked", self.apply_appearance, accent, font, size)
        actions.pack_start(apply_button, False, False, 0)
        picker = Gtk.Button(label="Elegir color")
        picker.connect("clicked", self.run_script, "accent_color_picker.sh")
        actions.pack_start(picker, False, False, 0)
        rofi_theme = Gtk.Button(label="Cambiar tema de Rofi")
        rofi_theme.connect("clicked", self.run_script, "rofi_theme_switcher.sh")
        actions.pack_start(rofi_theme, False, False, 0)
        opaque = Gtk.Button(label="Alternar modo opaco")
        opaque.connect("clicked", self.run_script, "opaque_theme.sh", "--toggle")
        actions.pack_start(opaque, False, False, 0)
        box.pack_start(actions, False, False, 0)
        box.pack_start(self.description(
            "Funciones que antes estaban en los menús Rofi de Tobimune."
        ), False, False, 0)
        for label, script, args in (
            ("Tobimune Shell", "tobimune_shell_mode.sh", ("--toggle",)),
            ("Wallpaper aleatorio", "random_wallpaper.sh", ("--toggle",)),
            ("Pantalla redondeada", "rounded_screen_manager.sh", ("--toggle",)),
            ("Posición dinámica", "rounded_screen_manager.sh", ("--toggle-dynamic",)),
            ("Edge trigger", "edge_trigger_manager.sh", ("--toggle",)),
            ("Tema opaco", "opaque_theme.sh", ("--toggle",)),
        ):
            button = Gtk.Button(label=label)
            button.connect("clicked", self.run_script, script, *args)
            box.pack_start(button, False, False, 0)
        page.pack_start(frame, False, False, 0)
        return page

    def waybar_page(self) -> Gtk.Widget:
        page = self.page("Waybar")
        current = state_file_value("waybar_current_mode", "top")
        page.pack_start(self.hero(
            "Waybar",
            "Selecciona uno de los estilos que ya existen en los dotfiles. "
            "La opción se aplica mediante waybar_manager.sh."
        ), False, False, 0)
        frame, box = self.section("Estilo activo")
        box.pack_start(self.value_label(current, "waybar-current"), False, False, 0)
        modes = Gtk.FlowBox()
        modes.set_selection_mode(Gtk.SelectionMode.NONE)
        modes.set_row_spacing(8)
        modes.set_column_spacing(8)
        for mode in ("top", "left", "island", "neon", "coredge", "minimal", "legacy"):
            button = Gtk.Button(label=mode)
            button.connect("clicked", self.apply_waybar_mode, mode)
            modes.add(button)
        box.pack_start(modes, False, False, 0)
        toggle = Gtk.Button(label="Alternar Waybar")
        toggle.connect("clicked", self.run_script, "waybar_manager.sh", "--toggle")
        box.pack_start(toggle, False, False, 0)
        page.pack_start(frame, False, False, 0)
        return page

    def desktop_page(self) -> Gtk.Widget:
        page = self.page("Escritorio")
        page.pack_start(self.hero(
            "Escritorio",
            "Funciones que ya tienen implementación en el shell: wallpapers "
            "aleatorios, fondos animados y selector visual."
        ), False, False, 0)
        frame, box = self.section("Wallpapers")
        for label, script, args in (
            ("Wallpaper aleatorio", "random_wallpaper.sh", ("--toggle",)),
            ("Wallpaper animado", "wallpaper_select.sh", ("--lively",)),
            ("Detener wallpaper animado", "wallpaper_select.sh", ("--exit",)),
        ):
            button = Gtk.Button(label=label)
            button.connect("clicked", self.run_script, script, *args)
            box.pack_start(button, False, False, 0)
        page.pack_start(frame, False, False, 0)
        return page

    def control_center_page(self) -> Gtk.Widget:
        page = self.page("Centro de control")
        page.pack_start(self.hero(
            "SwayNC y controles rápidos",
            "La GUI no reemplaza SwayNC: lo configura y abre sus controles "
            "cuando la acción ya existe en el sistema."
        ), False, False, 0)
        frame, box = self.section("Acciones disponibles")
        for label, command in (
            ("Abrir centro de control", ("swaync-client", "-t", "-sw")),
            ("Activar / desactivar No molestar", ("swaync-client", "-d")),
        ):
            button = Gtk.Button(label=label)
            button.connect("clicked", self.run_command, command)
            box.pack_start(button, False, False, 0)
        page.pack_start(frame, False, False, 0)
        return page

    def screens_page(self) -> Gtk.Widget:
        page = self.page("Pantallas")
        page.pack_start(self.hero(
            "Pantallas",
            "Los monitores y su disposición se mantienen en Hyprland. "
            "Esta acción ya disponible controla la luz nocturna."
        ), False, False, 0)
        frame, box = self.section("Luz nocturna")
        button = Gtk.Button(label="Alternar luz nocturna")
        button.connect("clicked", self.run_script, "nightlight_toggle.sh")
        box.pack_start(button, False, False, 0)
        page.pack_start(frame, False, False, 0)
        return page

    def tools_page(self) -> Gtk.Widget:
        page = self.page("Herramientas")
        page.pack_start(self.hero(
            "",
            "Accesos que ya existían en el menú general y que abren las "
            "herramientas instaladas del sistema."
        ), False, False, 0)
        frame, box = self.section("Acciones")
        actions = (
            ("Captura de pantalla", "screenshot.sh", ()),
            ("Grabación de pantalla", "record.sh", ()),
            ("Configuración de red", None, ("nm-connection-editor",)),
            ("Bluetooth", None, ("blueman-manager",)),
            ("Control de audio", None, ("pavucontrol",)),
            ("Abrir carpeta de configuración", None, ("xdg-open", str(Path.home() / "suzaku"))),
        )
        for label, script, args in actions:
            button = Gtk.Button(label=label)
            if script is not None:
                button.connect("clicked", self.run_script, script, *args)
            else:
                button.connect("clicked", self.run_command, args)
            box.pack_start(button, False, False, 0)
        page.pack_start(frame, False, False, 0)
        return page

    def open_wallpaper_dialog(self, _button: Gtk.Button) -> None:
        dialog = Gtk.Dialog(
            title="Tobimune Shell · Wallpapers",
            transient_for=self.window,
            modal=True,
        )
        dialog.set_default_size(760, 520)
        content = dialog.get_content_area()
        content.set_spacing(8)
        content.set_margin_top(16)
        content.set_margin_bottom(16)
        content.set_margin_start(16)
        content.set_margin_end(16)
        static_dir = setting_value("WALL_DIR", Path.home() / "Pictures/Wallpapers")
        files = sorted(
            [path for path in static_dir.glob("*") if path.suffix.lower() in WALLPAPER_EXTENSIONS]
            if static_dir.is_dir()
            else []
        )
        if not files:
            content.add(self.description(f"No se encontraron wallpapers en {static_dir}"))
        else:
            gallery = Gtk.FlowBox()
            gallery.set_selection_mode(Gtk.SelectionMode.NONE)
            gallery.set_row_spacing(10)
            gallery.set_column_spacing(10)
            gallery.set_max_children_per_line(4)
            for wallpaper in files[:40]:
                button = Gtk.Button()
                button.set_tooltip_text(wallpaper.name)
                card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
                try:
                    preview = GdkPixbuf.Pixbuf.new_from_file_at_scale(
                        str(wallpaper), 170, 100, True
                    )
                    card.pack_start(Gtk.Image.new_from_pixbuf(preview), False, False, 0)
                except GLib.Error:
                    card.pack_start(self.description("Sin vista previa"), False, False, 0)
                card.pack_start(self.description(wallpaper.name), False, False, 0)
                button.add(card)
                button.connect("clicked", self.apply_wallpaper, wallpaper, "static")
                gallery.add(button)
            content.add(gallery)
        dialog.add_button("Cerrar", Gtk.ResponseType.CLOSE)
        dialog.show_all()
        dialog.run()
        dialog.destroy()

    def apply_appearance(
        self,
        _button: Gtk.Button,
        accent: Gtk.Entry,
        font: Gtk.Entry,
        size: Gtk.SpinButton,
    ) -> None:
        generator = LOCAL_BIN / "gen_style.sh"
        applier = LOCAL_BIN / "apply_style.sh"
        command = (
            str(generator),
            accent.get_text().strip(),
            font.get_text().strip(),
            str(size.get_value_as_int()),
        )
        try:
            subprocess.run(command, check=True, capture_output=True, text=True)
            subprocess.run((str(applier),), check=True, capture_output=True, text=True)
            self.set_status("Tema aplicado en Waybar, Rofi, SwayNC y Kitty")
        except (OSError, subprocess.CalledProcessError) as error:
            self.set_status(f"No se pudo aplicar el tema: {error}")

    def apply_wallpaper(self, _button: Gtk.Button, wallpaper: Path, mode: str) -> None:
        self.run_script(_button, "wallpaper_select.sh", f"--{mode}", wallpaper.name)

    def run_script(self, _button: Gtk.Button, script: str, *args: str) -> None:
        path = LOCAL_BIN / script
        if not path.is_file():
            self.set_status(f"No se encontró {path}")
            return
        self.run_command(_button, (str(path), *args))

    def run_command(self, _button: Gtk.Button, command: tuple[str, ...]) -> None:
        try:
            subprocess.Popen(command, start_new_session=True)
            self.set_status(f"Ejecutado: {Path(command[0]).name}")
        except OSError as error:
            self.set_status(f"No se pudo ejecutar {command[0]}: {error}")

    def set_status(self, message: str) -> None:
        if self.status_label is not None:
            self.status_label.set_text(message)


if __name__ == "__main__":
    sys.exit(TobimuneGui().run(sys.argv))
