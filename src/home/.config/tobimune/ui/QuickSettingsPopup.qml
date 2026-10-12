import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: popupWindow

    // Posicionamiento en el extremo superior izquierdo (debajo del ícono ONI)
    anchors {
        top: true
        left: true
    }

    margins {
        top: 56
        left: 14
    }

    implicitWidth: 340
    implicitHeight: 470
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    // --- NAVEGACIÓN DE VISTAS (SUBMENÚS) ---
    // Valores posibles: "main", "wifi", "bluetooth", "power"
    property string currentSubMenu: "main"

    // --- ESTADOS Y CONTROLADORES DEL SISTEMA ---
    property bool wifiEnabled: true
    property string wifiSSID: "Cargando..."

    property bool btEnabled: root.btActive
    property string btDevice: "Sin conexión"

    property bool micMuted: false
    property string powerMode: "balanced" // options: "power-saver", "balanced", "performance"

    property int volumeLevel: parseInt(fusionRoot ? fusionRoot.volLevel : "50") || 50
    property int brightnessLevel: 75

    // MPRIS Media Metadata
    property string mediaTitle: "Sin reproducción"
    property string mediaArtist: "Playerctl"
    property string mediaArtUrl: ""
    property double mediaPosition: 0
    property double mediaLength: 0
    property string mediaStatus: "Stopped"

    // --- PROCESOS DE COMANDOS EN SISTEMA ---
    Process { id: toggleWifiProc; command: ["nmcli", "radio", "wifi", "toggle"] }
    Process { id: openWifiManagerProc; command: ["nm-connection-editor"] }

    Process { id: toggleBtProc; command: ["bluetoothctl", "power", "toggle"] }
    Process { id: openBtManagerProc; command: ["blueman-manager"] }

    Process { id: lockProc; command: ["hyprlock"] }
    Process { id: logoutProc; command: ["hyprctl", "dispatch", "exit"] }
    Process { id: shutdownProc; command: ["/home/starrk/.local/bin/shutdown.sh"] }

    // Procesos MPRIS
    Process { id: playPauseProc; command: ["playerctl", "play-pause"] }
    Process { id: prevTrackProc; command: ["playerctl", "previous"] }
    Process { id: nextTrackProc; command: ["playerctl", "next"] }

    // Funciones auxiliares de formato de tiempo
    function formatTime(seconds) {
        if (!seconds || isNaN(seconds) || seconds <= 0) return "0:00"
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }

    // Consulta periódica de datos (MPRIS, Wi-Fi, Perfil de Energía)
    Process {
        id: statusCollector
        command: ["bash", "-c", "playerctl metadata --format '{{title}}|||{{artist}}|||{{mpris:artUrl}}|||{{position}}|||{{mpris:length}}|||{{status}}' 2>/dev/null || true"]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split("|||")
                if (parts.length >= 6) {
                    popupWindow.mediaTitle = parts[0] !== "" ? parts[0] : "Sin reproducción"
                    popupWindow.mediaArtist = parts[1] !== "" ? parts[1] : "Media Player"
                    popupWindow.mediaArtUrl = parts[2]
                    popupWindow.mediaPosition = parseFloat(parts[3]) / 1000000.0 || 0
                    popupWindow.mediaLength = parseFloat(parts[4]) / 1000000.0 || 0
                    popupWindow.mediaStatus = parts[5]
                }
            }
        }
    }

    // Proceso para obtener SSID actual y perfil de energía activo
    Process {
        id: wifiInfoProc
        command: ["bash", "-c", "nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2"]
        stdout: SplitParser {
            onRead: data => {
                var ssid = data.trim()
                popupWindow.wifiSSID = ssid !== "" ? ssid : "Desconectado"
            }
        }
    }

    Process {
        id: powerProfileGetProc
        command: ["powerprofilesctl", "get"]
        stdout: SplitParser {
            onRead: data => {
                var profile = data.trim()
                if (profile !== "") popupWindow.powerMode = profile
            }
        }
    }

    Timer {
        interval: 1200
        running: popupWindow.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (popupWindow.visible) {
                statusCollector.running = true
                wifiInfoProc.running = true
                powerProfileGetProc.running = true
            }
        }
    }

    // --- CONTENEDOR PRINCIPAL ---
    Rectangle {
        id: bgCard
        anchors.fill: parent
        color: "#161616"
        radius: 18
        border.color: Qt.rgba(1, 1, 1, 0.12)
        border.width: 1
        clip: true

        // ==========================================
        // VISTA PRINCIPAL (MAIN VIEW)
        // ==========================================
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8
            visible: popupWindow.currentSubMenu === "main"

            // 1. GRID DE TOGGLES PRINCIPALES (Compacto 2x2)
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 6
                columnSpacing: 6

                // --- TOGGLE 1: WI-FI ---
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    radius: 10
                    color: popupWindow.wifiEnabled ? root.accentColor : Qt.rgba(1, 1, 1, 0.08)
                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 8
                        spacing: 6

                        // Zona principal del botón (Conmutar On/Off)
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                anchors.fill: parent
                                spacing: 8
                                Text {
                                    text: "󰤨"
                                    font.family: root.fontFamily
                                    font.pixelSize: 15
                                    color: popupWindow.wifiEnabled ? "#000000" : root.accentColor
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Text {
                                        text: "Wi-Fi"
                                        font.family: root.fontFamily
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: popupWindow.wifiEnabled ? "#000000" : "#ffffff"
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: popupWindow.wifiEnabled ? popupWindow.wifiSSID : "Apagado"
                                        font.family: root.fontFamily
                                        font.pixelSize: 9
                                        color: popupWindow.wifiEnabled ? Qt.rgba(0,0,0,0.7) : Qt.rgba(1,1,1,0.5)
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    popupWindow.wifiEnabled = !popupWindow.wifiEnabled
                                    toggleWifiProc.running = true
                                }
                            }
                        }

                        // Flecha para abrir Submenú
                        Rectangle {
                            implicitWidth: 22
                            implicitHeight: 22
                            radius: 11
                            color: Qt.rgba(0, 0, 0, 0.15)
                            Text {
                                anchors.centerIn: parent
                                text: "❯"
                                font.family: root.fontFamily
                                font.pixelSize: 9
                                color: popupWindow.wifiEnabled ? "#000000" : "#ffffff"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: popupWindow.currentSubMenu = "wifi"
                            }
                        }
                    }
                }

                // --- TOGGLE 2: BLUETOOTH ---
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    radius: 10
                    color: popupWindow.btEnabled ? root.accentColor : Qt.rgba(1, 1, 1, 0.08)
                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 8
                        spacing: 6

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                anchors.fill: parent
                                spacing: 8
                                Text {
                                    text: "󰂯"
                                    font.family: root.fontFamily
                                    font.pixelSize: 15
                                    color: popupWindow.btEnabled ? "#000000" : root.accentColor
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Text {
                                        text: "Bluetooth"
                                        font.family: root.fontFamily
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: popupWindow.btEnabled ? "#000000" : "#ffffff"
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: popupWindow.btEnabled ? "Activo" : "Apagado"
                                        font.family: root.fontFamily
                                        font.pixelSize: 9
                                        color: popupWindow.btEnabled ? Qt.rgba(0,0,0,0.7) : Qt.rgba(1,1,1,0.5)
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    popupWindow.btEnabled = !popupWindow.btEnabled
                                    toggleBtProc.running = true
                                }
                            }
                        }

                        Rectangle {
                            implicitWidth: 22
                            implicitHeight: 22
                            radius: 11
                            color: Qt.rgba(0, 0, 0, 0.15)
                            Text {
                                anchors.centerIn: parent
                                text: "❯"
                                font.family: root.fontFamily
                                font.pixelSize: 9
                                color: popupWindow.btEnabled ? "#000000" : "#ffffff"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: popupWindow.currentSubMenu = "bluetooth"
                            }
                        }
                    }
                }

                // --- TOGGLE 3: MODO DE ENERGÍA (PERFIL) ---
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    radius: 10
                    color: popupWindow.powerMode === "performance" ? root.accentColor : Qt.rgba(1, 1, 1, 0.08)
                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 8
                        spacing: 6

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                anchors.fill: parent
                                spacing: 8
                                Text {
                                    text: popupWindow.powerMode === "power-saver" ? "󰌪" : (popupWindow.powerMode === "performance" ? "󰓅" : "󰾅")
                                    font.family: root.fontFamily
                                    font.pixelSize: 15
                                    color: popupWindow.powerMode === "performance" ? "#000000" : root.accentColor
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Text {
                                        text: "Energía"
                                        font.family: root.fontFamily
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: popupWindow.powerMode === "performance" ? "#000000" : "#ffffff"
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: popupWindow.powerMode === "power-saver" ? "Ahorro" : (popupWindow.powerMode === "performance" ? "Rendimiento" : "Balanceado")
                                        font.family: root.fontFamily
                                        font.pixelSize: 9
                                        color: popupWindow.powerMode === "performance" ? Qt.rgba(0,0,0,0.7) : Qt.rgba(1,1,1,0.5)
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: popupWindow.currentSubMenu = "power"
                            }
                        }

                        Rectangle {
                            implicitWidth: 22
                            implicitHeight: 22
                            radius: 11
                            color: Qt.rgba(0, 0, 0, 0.15)
                            Text {
                                anchors.centerIn: parent
                                text: "❯"
                                font.family: root.fontFamily
                                font.pixelSize: 9
                                color: popupWindow.powerMode === "performance" ? "#000000" : "#ffffff"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: popupWindow.currentSubMenu = "power"
                            }
                        }
                    }
                }

                // --- TOGGLE 4: MICRÓFONO MUTE ---
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    radius: 10
                    color: popupWindow.micMuted ? root.accentColor : Qt.rgba(1, 1, 1, 0.08)
                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        Text {
                            text: popupWindow.micMuted ? "󰍭" : "󰍬"
                            font.family: root.fontFamily
                            font.pixelSize: 15
                            color: popupWindow.micMuted ? "#000000" : root.accentColor
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                text: "Micrófono"
                                font.family: root.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                color: popupWindow.micMuted ? "#000000" : "#ffffff"
                            }
                            Text {
                                text: popupWindow.micMuted ? "Muteado" : "Activo"
                                font.family: root.fontFamily
                                font.pixelSize: 9
                                color: popupWindow.micMuted ? Qt.rgba(0,0,0,0.7) : Qt.rgba(1,1,1,0.5)
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            popupWindow.micMuted = !popupWindow.micMuted
                            Quickshell.execute(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"])
                        }
                    }
                }
            }

            // 2. SLIDERS COMPACTOS DE VOLUMEN Y BRILLO
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                // Slider Volumen
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: 10
                    color: Qt.rgba(1, 1, 1, 0.08)
                    clip: true

                    Rectangle {
                        width: parent.width * Math.min(1.0, popupWindow.volumeLevel / 100.0)
                        height: parent.height
                        radius: 10
                        color: root.accentColor
                        Behavior on width { NumberAnimation { duration: 80 } }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        Text {
                            text: popupWindow.volumeLevel === 0 ? "󰝟" : "󰕾"
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            color: popupWindow.volumeLevel > 15 ? "#000000" : root.accentColor
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: popupWindow.volumeLevel + "%"
                            font.family: root.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            color: popupWindow.volumeLevel > 85 ? "#000000" : "#ffffff"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: (mouse) => {
                            if (pressed) {
                                var val = Math.max(0, Math.min(100, Math.round((mouse.x / width) * 100)))
                                popupWindow.volumeLevel = val
                                Quickshell.execute(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", val + "%"])
                            }
                        }
                        onClicked: (mouse) => {
                            var val = Math.max(0, Math.min(100, Math.round((mouse.x / width) * 100)))
                            popupWindow.volumeLevel = val
                            Quickshell.execute(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", val + "%"])
                        }
                    }
                }

                // Slider Brillo
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: 10
                    color: Qt.rgba(1, 1, 1, 0.08)
                    clip: true

                    Rectangle {
                        width: parent.width * Math.min(1.0, popupWindow.brightnessLevel / 100.0)
                        height: parent.height
                        radius: 10
                        color: root.accentColor
                        Behavior on width { NumberAnimation { duration: 80 } }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        Text {
                            text: "󰃠"
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            color: popupWindow.brightnessLevel > 15 ? "#000000" : root.accentColor
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: popupWindow.brightnessLevel + "%"
                            font.family: root.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            color: popupWindow.brightnessLevel > 85 ? "#000000" : "#ffffff"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: (mouse) => {
                            if (pressed) {
                                var val = Math.max(5, Math.min(100, Math.round((mouse.x / width) * 100)))
                                popupWindow.brightnessLevel = val
                                Quickshell.execute(["brightnessctl", "set", val + "%"])
                            }
                        }
                        onClicked: (mouse) => {
                            var val = Math.max(5, Math.min(100, Math.round((mouse.x / width) * 100)))
                            popupWindow.brightnessLevel = val
                            Quickshell.execute(["brightnessctl", "set", val + "%"])
                        }
                    }
                }
            }

            // 3. REPRODUCTOR DE MEDIOS MPRIS CON CARÁTULA E IMAGEN
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 14
                color: Qt.rgba(1, 1, 1, 0.05)
                border.color: Qt.rgba(1, 1, 1, 0.08)
                border.width: 1
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        // Carátula del Álbum / Imagen
                        Rectangle {
                            implicitWidth: 60
                            implicitHeight: 60
                            radius: 10
                            color: Qt.rgba(1, 1, 1, 0.1)
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: popupWindow.mediaArtUrl !== "" ? popupWindow.mediaArtUrl : ""
                                fillMode: Image.PreserveAspectCrop
                                visible: popupWindow.mediaArtUrl !== ""
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰎆"
                                font.family: root.fontFamily
                                font.pixelSize: 24
                                color: root.accentColor
                                visible: popupWindow.mediaArtUrl === ""
                            }
                        }

                        // Título y Artista
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: popupWindow.mediaTitle
                                font.family: root.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                                color: "#ffffff"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: popupWindow.mediaArtist
                                font.family: root.fontFamily
                                font.pixelSize: 10
                                color: Qt.rgba(1, 1, 1, 0.6)
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // Barra de Progreso y Tiempo
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 4
                            radius: 2
                            color: Qt.rgba(1, 1, 1, 0.15)

                            Rectangle {
                                width: popupWindow.mediaLength > 0 ? parent.width * Math.min(1.0, popupWindow.mediaPosition / popupWindow.mediaLength) : 0
                                height: parent.height
                                radius: 2
                                color: root.accentColor
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: popupWindow.formatTime(popupWindow.mediaPosition)
                                font.family: root.fontFamily
                                font.pixelSize: 9
                                color: Qt.rgba(1, 1, 1, 0.5)
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: popupWindow.formatTime(popupWindow.mediaLength)
                                font.family: root.fontFamily
                                font.pixelSize: 9
                                color: Qt.rgba(1, 1, 1, 0.5)
                            }
                        }
                    }

                    // Botones de Reproducción
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 24

                        Text {
                            text: "󰒮"
                            font.family: root.fontFamily
                            font.pixelSize: 18
                            color: "#ffffff"
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: prevTrackProc.running = true
                            }
                        }

                        Rectangle {
                            implicitWidth: 32
                            implicitHeight: 32
                            radius: 16
                            color: root.accentColor

                            Text {
                                anchors.centerIn: parent
                                text: popupWindow.mediaStatus === "Playing" ? "󰏤" : "󰐊"
                                font.family: root.fontFamily
                                font.pixelSize: 14
                                color: "#000000"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: playPauseProc.running = true
                            }
                        }

                        Text {
                            text: "󰒭"
                            font.family: root.fontFamily
                            font.pixelSize: 18
                            color: "#ffffff"
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: nextTrackProc.running = true
                            }
                        }
                    }
                }
            }

            // 4. TARJETA INFERIOR: USUARIO + BATERÍA + SESIÓN (Como Imagen 1)
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 50
                radius: 14
                color: Qt.rgba(1, 1, 1, 0.05)
                border.color: Qt.rgba(1, 1, 1, 0.08)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    // Avatar de usuario
                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: 16
                        color: Qt.rgba(1, 1, 1, 0.1)
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: "file:///home/starrk/.face"
                            fillMode: Image.PreserveAspectCrop
                        }
                    }

                    // Batería e Info
                    ColumnLayout {
                        spacing: 0
                        RowLayout {
                            spacing: 4
                            Text {
                                text: fusionRoot && fusionRoot.isCharging ? "󰂄" : "󰁹"
                                font.family: root.fontFamily
                                font.pixelSize: 12
                                color: root.accentColor
                            }
                            Text {
                                text: fusionRoot ? fusionRoot.batLevel : "100%"
                                font.family: root.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                color: "#ffffff"
                            }
                        }
                        Text {
                            text: fusionRoot && fusionRoot.isCharging ? "Cargando" : "En uso"
                            font.family: root.fontFamily
                            font.pixelSize: 9
                            color: Qt.rgba(1, 1, 1, 0.5)
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Botones de Sesión
                    RowLayout {
                        spacing: 6

                        Rectangle {
                            implicitWidth: 32
                            implicitHeight: 32
                            radius: 16
                            color: Qt.rgba(1, 1, 1, 0.08)
                            Text {
                                anchors.centerIn: parent
                                text: "󰌾"
                                font.family: root.fontFamily
                                font.pixelSize: 13
                                color: "#ffffff"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.quickSettingsOpen = false
                                    lockProc.running = true
                                }
                            }
                        }

                        Rectangle {
                            implicitWidth: 32
                            implicitHeight: 32
                            radius: 16
                            color: Qt.rgba(1, 1, 1, 0.08)
                            Text {
                                anchors.centerIn: parent
                                text: "󰍃"
                                font.family: root.fontFamily
                                font.pixelSize: 13
                                color: "#ffffff"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.quickSettingsOpen = false
                                    logoutProc.running = true
                                }
                            }
                        }

                        Rectangle {
                            implicitWidth: 32
                            implicitHeight: 32
                            radius: 16
                            color: Qt.rgba(0.95, 0.34, 0.34, 0.25)
                            Text {
                                anchors.centerIn: parent
                                text: "󰐥"
                                font.family: root.fontFamily
                                font.pixelSize: 13
                                color: "#f38ba8"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.quickSettingsOpen = false
                                    shutdownProc.running = true
                                }
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // VISTA DE SUBMENÚ: MODO DE ENERGÍA
        // ==========================================
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10
            visible: popupWindow.currentSubMenu === "power"

            // Encabezado
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Rectangle {
                    implicitWidth: 28
                    implicitHeight: 28
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.1)
                    Text {
                        anchors.centerIn: parent
                        text: "󰁍"
                        font.family: root.fontFamily
                        font.pixelSize: 14
                        color: "#ffffff"
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popupWindow.currentSubMenu = "main"
                    }
                }
                Text {
                    text: "Perfil de Energía"
                    font.family: root.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    color: "#ffffff"
                }
            }

            // Opciones de Perfiles
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                // 1. Power Saver
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 48
                    radius: 12
                    color: popupWindow.powerMode === "power-saver" ? root.accentColor : Qt.rgba(1, 1, 1, 0.08)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        spacing: 10
                        Text {
                            text: "󰌪"
                            font.family: root.fontFamily
                            font.pixelSize: 18
                            color: popupWindow.powerMode === "power-saver" ? "#000000" : root.accentColor
                        }
                        ColumnLayout {
                            spacing: 0
                            Text {
                                text: "Ahorro de Energía"
                                font.family: root.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                                color: popupWindow.powerMode === "power-saver" ? "#000000" : "#ffffff"
                            }
                            Text {
                                text: "Minimiza el consumo para mayor batería"
                                font.family: root.fontFamily
                                font.pixelSize: 9
                                color: popupWindow.powerMode === "power-saver" ? Qt.rgba(0,0,0,0.7) : Qt.rgba(1,1,1,0.5)
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            popupWindow.powerMode = "power-saver"
                            Quickshell.execute(["powerprofilesctl", "set", "power-saver"])
                        }
                    }
                }

                // 2. Balanced
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 48
                    radius: 12
                    color: popupWindow.powerMode === "balanced" ? root.accentColor : Qt.rgba(1, 1, 1, 0.08)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        spacing: 10
                        Text {
                            text: "󰾅"
                            font.family: root.fontFamily
                            font.pixelSize: 18
                            color: popupWindow.powerMode === "balanced" ? "#000000" : root.accentColor
                        }
                        ColumnLayout {
                            spacing: 0
                            Text {
                                text: "Balanceado"
                                font.family: root.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                                color: popupWindow.powerMode === "balanced" ? "#000000" : "#ffffff"
                            }
                            Text {
                                text: "Equilibrio estándar entre batería y velocidad"
                                font.family: root.fontFamily
                                font.pixelSize: 9
                                color: popupWindow.powerMode === "balanced" ? Qt.rgba(0,0,0,0.7) : Qt.rgba(1,1,1,0.5)
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            popupWindow.powerMode = "balanced"
                            Quickshell.execute(["powerprofilesctl", "set", "balanced"])
                        }
                    }
                }

                // 3. Performance
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 48
                    radius: 12
                    color: popupWindow.powerMode === "performance" ? root.accentColor : Qt.rgba(1, 1, 1, 0.08)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        spacing: 10
                        Text {
                            text: "󰓅"
                            font.family: root.fontFamily
                            font.pixelSize: 18
                            color: popupWindow.powerMode === "performance" ? "#000000" : root.accentColor
                        }
                        ColumnLayout {
                            spacing: 0
                            Text {
                                text: "Alto Rendimiento"
                                font.family: root.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                                color: popupWindow.powerMode === "performance" ? "#000000" : "#ffffff"
                            }
                            Text {
                                text: "Máxima potencia para juegos y cargas pesadas"
                                font.family: root.fontFamily
                                font.pixelSize: 9
                                color: popupWindow.powerMode === "performance" ? Qt.rgba(0,0,0,0.7) : Qt.rgba(1,1,1,0.5)
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            popupWindow.powerMode = "performance"
                            Quickshell.execute(["powerprofilesctl", "set", "performance"])
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }

        // ==========================================
        // VISTA DE SUBMENÚ: WI-FI
        // ==========================================
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12
            visible: popupWindow.currentSubMenu === "wifi"

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Rectangle {
                    implicitWidth: 28
                    implicitHeight: 28
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.1)
                    Text {
                        anchors.centerIn: parent
                        text: "󰁍"
                        font.family: root.fontFamily
                        font.pixelSize: 14
                        color: "#ffffff"
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popupWindow.currentSubMenu = "main"
                    }
                }
                Text {
                    text: "Ajustes de Wi-Fi"
                    font.family: root.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    color: "#ffffff"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 50
                radius: 12
                color: Qt.rgba(1, 1, 1, 0.08)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    Text {
                        text: "Red Actual:"
                        font.family: root.fontFamily
                        font.pixelSize: 12
                        color: "#ffffff"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: popupWindow.wifiSSID
                        font.family: root.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        color: root.accentColor
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 44
                radius: 10
                color: root.accentColor

                Text {
                    anchors.centerIn: parent
                    text: "Abrir Gestor de Conexiones"
                    font.family: root.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    color: "#000000"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        openWifiManagerProc.running = true
                        popupWindow.currentSubMenu = "main"
                        root.quickSettingsOpen = false
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }

        // ==========================================
        // VISTA DE SUBMENÚ: BLUETOOTH
        // ==========================================
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12
            visible: popupWindow.currentSubMenu === "bluetooth"

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Rectangle {
                    implicitWidth: 28
                    implicitHeight: 28
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.1)
                    Text {
                        anchors.centerIn: parent
                        text: "󰁍"
                        font.family: root.fontFamily
                        font.pixelSize: 14
                        color: "#ffffff"
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popupWindow.currentSubMenu = "main"
                    }
                }
                Text {
                    text: "Ajustes de Bluetooth"
                    font.family: root.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    color: "#ffffff"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 50
                radius: 12
                color: Qt.rgba(1, 1, 1, 0.08)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    Text {
                        text: "Estado:"
                        font.family: root.fontFamily
                        font.pixelSize: 12
                        color: "#ffffff"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: popupWindow.btEnabled ? "Encendido" : "Apagado"
                        font.family: root.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        color: popupWindow.btEnabled ? root.accentColor : "#f38ba8"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 44
                radius: 10
                color: root.accentColor

                Text {
                    anchors.centerIn: parent
                    text: "Abrir Dispositivos Bluetooth"
                    font.family: root.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    color: "#000000"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        openBtManagerProc.running = true
                        popupWindow.currentSubMenu = "main"
                        root.quickSettingsOpen = false
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}