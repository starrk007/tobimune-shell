import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: waybarClone
    
    anchors { top: true; left: true; right: true }
    implicitHeight: 56 
    color: "transparent"
    exclusiveZone: 56

    // Procesos para la barra
    Process { id: menuProc; command: ["/home/starrk/.local/bin/tobimune-menu.sh"] }
    Process { id: suzakuProc; command: ["xdg-open", "/home/starrk/suzaku/"] }
    Process { id: shutdownProc; command: ["/home/starrk/.local/bin/shutdown.sh"] }
    Process { id: swayncProc; command: ["swaync-client", "-t"] }

    Item {
        anchors.fill: parent
        anchors.topMargin: 12 
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        // ==========================================
        // IZQUIERDA
        // ==========================================
        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Pill {
                SysButton { icon: "\uf002"; onClicked: menuProc.running = true }
                SysButton { icon: "\uf013"; onClicked: suzakuProc.running = true }
            }
            
            Pill {
                Row {
                    spacing: 6
                    Repeater {
                        model: 5
                        Rectangle {
                            width: index === 0 ? 30 : 10
                            height: 10
                            radius: 3
                            color: index === 0 ? root.accentColor : Qt.rgba(0.53, 0.7, 0.98, 0.3)
                            Behavior on width { NumberAnimation { duration: 250 } }
                            Behavior on color { ColorAnimation { duration: 250 } }
                        }
                    }
                }
            }

            Pill {
                SysButton { icon: "\uf04c"; textData: "Fedelobo Reacciona..." }
            }
        }

        // ==========================================
        // CENTRO
        // ==========================================
        Pill {
            anchors.centerIn: parent
            SysButton {
                textData: Qt.formatDateTime(new Date(), "hh:mm:ss, dd MMMM yyyy")
                Timer {
                    interval: 1000; running: true; repeat: true
                    onTriggered: parent.textData = Qt.formatDateTime(new Date(), "hh:mm:ss, dd MMMM yyyy")
                }
            }
        }

        // ==========================================
        // DERECHA
        // ==========================================
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            // CPU y RAM
            Pill {
                SysButton { icon: "\uf2db"; textData: "12%" } 
                SysButton { icon: "\ue266"; textData: "4.2G" } 
            }

            // Volumen y Batería (Despliegan el panel)
            Pill {
                SysButton { 
                    icon: "\uf028" 
                    onClicked: root.quickSettingsOpen = !root.quickSettingsOpen
                } 
                SysButton { 
                    icon: "󰁹"
                    textData: "100%" 
                    onClicked: root.quickSettingsOpen = !root.quickSettingsOpen
                } 
            }

            // Red y Bluetooth
            Pill {
                SysButton { icon: "\uf108"; onClicked: root.quickSettingsOpen = !root.quickSettingsOpen }
                SysButton { icon: "\uf293"; onClicked: root.quickSettingsOpen = !root.quickSettingsOpen }
            }

            // Herramientas
            Pill {
                SysButton { icon: "\uf06c"; onClicked: root.quickSettingsOpen = !root.quickSettingsOpen } 
                SysButton { icon: "\uf011"; onClicked: shutdownProc.running = true } 
                SysButton { icon: "\uf0f3"; onClicked: swayncProc.running = true } 
            }
        }
    }
}
