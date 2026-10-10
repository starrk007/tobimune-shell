
#!/usr/bin/env python3
"""Tobimune rounded screen app."""

import os
import sys
import math
import configparser
import gi
import cairo

gi.require_version("Gtk", "3.0")

try:
    gi.require_version("GtkLayerShell", "0.1")
except ValueError:
    print("Error: GtkLayerShell is not installed.")
    sys.exit(1)

from gi.repository import Gtk, Gdk, GtkLayerShell, GLib

CONFIG_DIR = os.path.expanduser("~/suzaku/config")
CONF_FILE = os.path.join(CONFIG_DIR, "rounded-screen.conf")

BORDER_THICKNESS = 4
BORDER_RADIUS = 20
DYNAMIC_POSITION = True


def load_config():
    global BORDER_THICKNESS, BORDER_RADIUS, DYNAMIC_POSITION

    os.makedirs(CONFIG_DIR, exist_ok=True)
    config = configparser.ConfigParser()

    default_settings = f"""[Settings]
# Border thickness in pixels
border_thickness = {BORDER_THICKNESS}

# Border radius in pixels
border_radius = {BORDER_RADIUS}

# Make rounded screen dynamic (affected by waybar/panels)
dynamic_position = {DYNAMIC_POSITION}
"""

    if not os.path.exists(CONF_FILE):
        try:
            with open(CONF_FILE, "w") as configfile:
                configfile.write(default_settings)
        except OSError as e:
            print(f"Failed to create config file {CONF_FILE}: {e}")
        return

    try:
        config.read(CONF_FILE)

        if "Settings" not in config:
            return

        settings = config["Settings"]

        BORDER_THICKNESS = max(
            0, settings.getint("border_thickness", BORDER_THICKNESS)
        )
        BORDER_RADIUS = max(
            1, settings.getint("border_radius", BORDER_RADIUS)
        )
        DYNAMIC_POSITION = settings.getboolean(
            "dynamic_position", DYNAMIC_POSITION
        )

    except (ValueError, configparser.Error, OSError) as e:
        print(f"Failed to parse {CONF_FILE}: {e}")


def make_click_through(win):
    """Keep the window transparent to mouse input."""

    region = cairo.Region()

    def apply_shape(*_args):
        win.input_shape_combine_region(region)

    win.connect("realize", apply_shape)
    win.connect("size-allocate", apply_shape)


def configure_transparency(win):
    screen = win.get_screen()
    visual = screen.get_rgba_visual()

    if visual:
        win.set_visual(visual)

    win.set_app_paintable(True)


def create_invisible_edge(edge, size, monitor, monitor_index):
    """Reserve space for panels on one specific monitor."""

    if size <= 0:
        return None

    win = Gtk.Window()
    GtkLayerShell.init_for_window(win)

    # Assign this window to its monitor before mapping it.
    GtkLayerShell.set_monitor(win, monitor)
    GtkLayerShell.set_layer(win, GtkLayerShell.Layer.BOTTOM)

    edge_names = {
        GtkLayerShell.Edge.TOP: "top",
        GtkLayerShell.Edge.BOTTOM: "bottom",
        GtkLayerShell.Edge.LEFT: "left",
        GtkLayerShell.Edge.RIGHT: "right",
    }

    edge_name = edge_names[edge]
    namespace = f"rounded-corner-{monitor_index}-{edge_name}"

    GtkLayerShell.set_namespace(win, namespace)
    win.set_wmclass(namespace, namespace)

    GtkLayerShell.set_anchor(win, edge, True)

    if edge in (GtkLayerShell.Edge.TOP, GtkLayerShell.Edge.BOTTOM):
        GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.LEFT, True)
        GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.RIGHT, True)
        win.set_size_request(-1, size)
    else:
        GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.BOTTOM, True)
        win.set_size_request(size, -1)

    GtkLayerShell.auto_exclusive_zone_enable(win)

    configure_transparency(win)
    win.connect("draw", lambda _w, _cr: False)
    make_click_through(win)
    win.show_all()

    return win


def on_draw_main(widget, cr):
    width = widget.get_allocated_width()
    height = widget.get_allocated_height()

    if width <= 0 or height <= 0:
        return False

    radius = min(BORDER_RADIUS, width / 2, height / 2)
    thickness = BORDER_THICKNESS

    # Clear the window to transparent.
    cr.set_operator(cairo.OPERATOR_SOURCE)
    cr.set_source_rgba(0, 0, 0, 0)
    cr.paint()

    # Outer rectangle and inner rounded rectangle.
    cr.rectangle(0, 0, width, height)

    cr.new_sub_path()
    cr.arc(
        width - radius, radius, radius,
        -math.pi / 2, 0
    )
    cr.arc(
        width - radius, height - radius, radius,
        0, math.pi / 2
    )
    cr.arc(
        radius, height - radius, radius,
        math.pi / 2, math.pi
    )
    cr.arc(
        radius, radius, radius,
        math.pi, 3 * math.pi / 2
    )
    cr.close_path()

    cr.set_fill_rule(cairo.FILL_RULE_EVEN_ODD)
    cr.set_source_rgba(0, 0, 0, 1.0)
    cr.fill_preserve()

    if thickness > 0:
        cr.set_line_width(thickness * 2)
        cr.stroke()

    return False


def create_main_window(monitor, monitor_index):
    """Create the rounded-screen drawing window for one monitor."""

    win = Gtk.Window()
    win.set_title(f"Rounded Screen {monitor_index + 1}")

    GtkLayerShell.init_for_window(win)

    # Each window belongs to a specific physical monitor.
    GtkLayerShell.set_monitor(win, monitor)

    if DYNAMIC_POSITION:
        GtkLayerShell.set_layer(win, GtkLayerShell.Layer.TOP)
    else:
        GtkLayerShell.set_layer(win, GtkLayerShell.Layer.OVERLAY)

    namespace = f"rounded-screen-{monitor_index}"
    GtkLayerShell.set_namespace(win, namespace)
    win.set_wmclass(namespace, namespace)

    GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.TOP, True)
    GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.BOTTOM, True)
    GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.LEFT, True)
    GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.RIGHT, True)

    if DYNAMIC_POSITION:
        GtkLayerShell.set_exclusive_zone(win, 0)
    else:
        GtkLayerShell.set_exclusive_zone(win, -1)

    configure_transparency(win)
    win.connect("draw", on_draw_main)
    make_click_through(win)
    win.show_all()

    return win


def main():
    GLib.set_prgname("rounded-screen")
    GLib.set_application_name("rounded-screen")

    load_config()

    display = Gdk.Display.get_default()

    if display is None:
        print("Error: no graphical display is available.")
        sys.exit(1)

    monitor_count = display.get_n_monitors()

    if monitor_count == 0:
        print("Error: no monitors were detected.")
        sys.exit(1)

    windows = []

    print(f"Rounded Screen: detected {monitor_count} monitor(s).")

    for monitor_index in range(monitor_count):
        monitor = display.get_monitor(monitor_index)

        if monitor is None:
            print(f"Warning: monitor {monitor_index} could not be accessed.")
            continue

        # Main drawing window for this monitor.
        main_win = create_main_window(monitor, monitor_index)
        windows.append(main_win)

        # In fixed-position mode, reserve the border space per monitor.
        if not DYNAMIC_POSITION and BORDER_THICKNESS > 0:
            edges = (
                GtkLayerShell.Edge.TOP,
                GtkLayerShell.Edge.BOTTOM,
                GtkLayerShell.Edge.LEFT,
                GtkLayerShell.Edge.RIGHT,
            )

            for edge in edges:
                edge_win = create_invisible_edge(
                    edge,
                    BORDER_THICKNESS,
                    monitor,
                    monitor_index,
                )

                if edge_win is not None:
                    windows.append(edge_win)

    if not windows:
        print("Error: no Rounded Screen windows could be created.")
        sys.exit(1)

    print(f"Rounded Screen: created {len(windows)} window(s).")
    Gtk.main()


if __name__ == "__main__":
    main()
