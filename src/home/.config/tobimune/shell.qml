import QtQuick
import Quickshell
import Quickshell.Wayland
import "./ui"

ShellRoot {
    id: root
    
    property color accentColor: "#89b4fa"
    property color frameColor: "#11111b"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property string currentTheme: "TopBarFusion.qml"
    
    // Estado global para mostrar u ocultar el menú desplegable
    property bool quickSettingsOpen: false

    function loadAccentColor() {
        var xhr = new XMLHttpRequest();
        // Ruta limpia, sin el "?t="
        xhr.open("GET", "file:///home/starrk/.local/state/tobimune/theme/colors.css", true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var match = xhr.responseText.match(/@define-color accent_color\s+(#[0-9a-fA-F]{6})/);
                if (match && match[1]) {
                    root.accentColor = match[1];
                }
            }
        }
        xhr.send();
    }

    Component.onCompleted: {
        loadAccentColor()
    }

 	Instantiator {
 	        model: Quickshell.screens 
 	        
 	        delegate: Loader {
 	            Component.onCompleted: {
 	                // Inyectamos el monitor en una propiedad personalizada llamada "targetScreen"
 	                setSource("ui/" + root.currentTheme, { "targetScreen": modelData })
 	            }
 	
 	            Connections {
 	                target: root
 	                function onCurrentThemeChanged() {
 	                    setSource("ui/" + root.currentTheme, { "targetScreen": modelData })
 	                }
 	            }
 	        }
 	 }

    // El menú desplegable como una ventana INDEPENDIENTE en la raíz
    QuickSettingsPopup {
        visible: root.quickSettingsOpen
    }
}
