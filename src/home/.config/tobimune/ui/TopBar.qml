import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: topBar
    
    anchors {
        top: true
        left: true
        right: true
    }
    
    // 10px del marco + 34px de barra colgante = 44px totales
    height: 44
    color: "transparent"
    exclusiveZone: height // Hyprland reservará este espacio para no tapar ventanas

    // ==========================================
    // COMPONENTE REUTILIZABLE: Botón Interactivo
    // ==========================================
    component SysButton: Rectangle {
        id: btn
        property string icon: ""
        property string textData: ""
        property color iconColor: "#cdd6f4"
        signal clicked()

        width: row.width + 24
        height: 28
        radius: 14
        // Fondo iluminado al pasar el ratón
        color: mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } } // Transición suave

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 8
            Text { 
                text: btn.icon
                color: btn.iconColor
                font.family: root.fontFamily
                font.pixelSize: 15 
            }
            Text { 
                text: btn.textData
                visible: btn.textData !== ""
                color: "#cdd6f4"
                font.family: root.fontFamily
                font.pixelSize: 13
                font.bold: true 
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: btn.clicked()
        }
    }

    // ==========================================
    // 1. EL TECHO (Conecta todo con los marcos laterales)
    // ==========================================
    Rectangle {
        id: ceiling
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.frameThickness // Los 10px de tu marco
        color: root.frameColor
    }

    // ==========================================
    // 2. MONTAÑA IZQUIERDA (Menú y Workspaces)
    // ==========================================
    Rectangle {
        anchors.top: ceiling.bottom
        anchors.left: parent.left
        width: 250
        height: parent.height - root.frameThickness
        color: root.frameColor
        radius: 16
        
        // Máscaras para fusionar perfectamente con el techo y el marco izquierdo
        Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 16; color: root.frameColor }
        Rectangle { anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.left: parent.left; width: 16; color: root.frameColor }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 16
            spacing: 12

            // Botón de Lanzador de Apps
            SysButton {
                icon: "\uf303" // Icono Arch/Linux
                iconColor: root.accentColor
                onClicked: console.log("Desplegar Menú Principal") // Aquí abriremos Rofi luego
            }

            // Workspaces (Animados)
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                Repeater {
                    model: 5
                    Rectangle {
                        width: index === 0 ? 24 : 8
                        height: 8
                        radius: 4
                        color: index === 0 ? root.accentColor : Qt.rgba(1, 1, 1, 0.2)
                        Behavior on width { NumberAnimation { duration: 300 } }
                        Behavior on color { ColorAnimation { duration: 300 } }
                    }
                }
            }
        }
    }

    // ==========================================
    // 3. MONTAÑA CENTRAL (Reloj y Calendario)
    // ==========================================
    Rectangle {
        anchors.top: ceiling.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 140
        height: parent.height - root.frameThickness
        color: root.frameColor
        radius: 16
        
        // Fusión con el techo
        Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 16; color: root.frameColor }

        SysButton {
            anchors.centerIn: parent
            icon: "\uf017"
            iconColor: root.accentColor
            textData: Qt.formatDateTime(new Date(), "hh:mm")
            onClicked: console.log("Desplegar Calendario")
            
            Timer {
                interval: 60000; running: true; repeat: true
                onTriggered: parent.textData = Qt.formatDateTime(new Date(), "hh:mm")
            }
        }
    }

    // ==========================================
    // 4. MONTAÑA DERECHA (Quick Settings)
    // ==========================================
    Rectangle {
        anchors.top: ceiling.bottom
        anchors.right: parent.right
        width: 380
        height: parent.height - root.frameThickness
        color: root.frameColor
        radius: 16
        
        // Máscaras para fusionar perfectamente con el techo y el marco derecho
        Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 16; color: root.frameColor }
        Rectangle { anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.right: parent.right; width: 16; color: root.frameColor }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 16
            spacing: 2

            // Panel de Control / Quick Settings
            SysButton { icon: "\uf1eb"; iconColor: "#a6e3a1"; onClicked: console.log("Menú WiFi") }
            SysButton { icon: "\uf293"; iconColor: "#89b4fa"; onClicked: console.log("Menú Bluetooth") }
            SysButton { icon: "\uf028"; textData: "75%"; iconColor: "#f38ba8"; onClicked: console.log("Menú Volumen") }
            SysButton { icon: "\uf241"; textData: "80%"; iconColor: "#f9e2af"; onClicked: console.log("Menú Batería") }
            
            // Separador sutil
            Rectangle { width: 1; height: 16; color: Qt.rgba(1, 1, 1, 0.2); anchors.verticalCenter: parent.verticalCenter }
            
            // Botón de Apagado (Reemplazo futuro de wlogout)
            SysButton { icon: "\uf011"; iconColor: "#f38ba8"; onClicked: console.log("Power Menu") }
        }
    }
}
