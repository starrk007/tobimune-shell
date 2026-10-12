import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Layouts
import Quickshell.Hyprland

Item {
    id: fusionRoot
    
    property var targetScreen

    readonly property color bgDark: "#161616" 
    readonly property int frameThickness: 10
    readonly property int topBarHeight: 50
    readonly property int cornerRadius: 16

    // --- PROPIEDADES DE ESTADO ---
    property string cpuUsage: "0%"
    property string ramUsage: "0G"
    property string volLevel: "0%"
    property string batLevel: "100%"
    property bool isCharging: false
    property string netIcon: "󰤨"
    property bool btActive: false

    // --- PROCESO ÚNICO DE LECTURA (JSON) ---
    Process {
        id: statsProc
        command: ["/home/starrk/.local/bin/bar_stats.sh"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var stats = JSON.parse(data.trim())
                    fusionRoot.cpuUsage = stats.cpu
                    fusionRoot.ramUsage = stats.ram
                    fusionRoot.volLevel = stats.vol
                    fusionRoot.batLevel = stats.bat
                    fusionRoot.isCharging = stats.charging
                    fusionRoot.netIcon = stats.net
                    fusionRoot.btActive = stats.bt
                } catch(e) {}
            }
        }
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statsProc.running = true
    }

    // ==========================================
    // 1. BARRA SUPERIOR
    // ==========================================
    PanelWindow {
        id: topBarWindow
        screen: fusionRoot.targetScreen
        anchors { top: true; left: true; right: true }
        implicitHeight: fusionRoot.topBarHeight
        exclusiveZone: fusionRoot.topBarHeight
        color: fusionRoot.bgDark

        Item {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                SysButton { 
                    icon: "file:///home/starrk/.config/tobimune/assets/oni.png"
                    iconSize: 36 
                    alwaysInverted: true
                    onClicked: root.quickSettingsOpen = !root.quickSettingsOpen
                }
                
                RowLayout {
                    spacing: 8
                    Repeater {
                        model: Hyprland.workspaces
                        Rectangle {
                            required property var modelData
                            readonly property bool isOnThisMonitor: fusionRoot.targetScreen && modelData.monitor && modelData.monitor.name === fusionRoot.targetScreen.name
                            visible: isOnThisMonitor
               
                            Layout.preferredWidth: modelData.focused ? 50 : 22
                            Layout.preferredHeight: 22
                            Layout.alignment: Qt.AlignVCenter
                            radius: 6
                            color: modelData.focused 
                                   ? root.accentColor 
                                   : Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.25)
               
                            Behavior on Layout.preferredWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation { duration: 200 } }
               
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: modelData.activate()
                            }
                        }
                    }
                }
            }

            SysButton {
                anchors.centerIn: parent
                textData: Qt.formatDateTime(new Date(), "hh:mm:ss, dd MMMM yyyy")
                Timer {
                    interval: 1000; running: true; repeat: true
                    onTriggered: parent.textData = Qt.formatDateTime(new Date(), "hh:mm:ss, dd MMMM yyyy")
                }
            }

            Row {
                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                SysButton { icon: "\uf2db"; textData: fusionRoot.cpuUsage; alwaysInverted: true }
                SysButton { icon: "\ue266"; textData: fusionRoot.ramUsage; alwaysInverted: true }
                
                SysButton { icon: fusionRoot.netIcon; alwaysInverted: true }
                SysButton { icon: "󰂯"; visible: fusionRoot.btActive; alwaysInverted: true }

                SysButton { icon: "󰕾"; textData: fusionRoot.volLevel; alwaysInverted: true }
                SysButton { 
                    icon: fusionRoot.isCharging ? "󰂄" : "󰁹"
                    textData: fusionRoot.batLevel
                    alwaysInverted: true 
                }
                
                Rectangle { width: 1; height: 18; color: Qt.rgba(1,1,1,0.2); anchors.verticalCenter: parent.verticalCenter }
                
                SysButton { 
                    icon: "\uf0f3"
                    alwaysInverted: true
                    onClicked: Quickshell.execute("swaync-client -t") 
                }

                SysButton { 
                    icon: "\uf011"
                    alwaysInverted: true
                    onClicked: Quickshell.execute("/home/starrk/.local/bin/shutdown.sh") 
                }
            }
        }
    }

    // ==========================================
    // 2. MARCOS Y ESQUINAS
    // ==========================================
    PanelWindow {
        screen: fusionRoot.targetScreen
        anchors { bottom: true; left: true; right: true }
        implicitHeight: fusionRoot.frameThickness
        exclusionMode: ExclusionMode.Ignore
        color: fusionRoot.bgDark
    }

    PanelWindow {
        screen: fusionRoot.targetScreen
        anchors { top: true; bottom: true; left: true }
        implicitWidth: fusionRoot.frameThickness + fusionRoot.cornerRadius
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        Rectangle {
            anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.left: parent.left
            width: fusionRoot.frameThickness
            color: fusionRoot.bgDark
        }

        Shape {
            x: fusionRoot.frameThickness; y: fusionRoot.topBarHeight
            width: fusionRoot.cornerRadius; height: fusionRoot.cornerRadius
            ShapePath {
                fillColor: fusionRoot.bgDark; strokeColor: "transparent"
                startX: 0; startY: fusionRoot.cornerRadius
                PathArc { x: fusionRoot.cornerRadius; y: 0; radiusX: fusionRoot.cornerRadius; radiusY: fusionRoot.cornerRadius; direction: PathArc.Clockwise; useLargeArc: false }
                PathLine { x: 0; y: 0 }
                PathLine { x: 0; y: fusionRoot.cornerRadius }
            }
        }

        Shape {
            x: fusionRoot.frameThickness; y: parent.height - fusionRoot.frameThickness - fusionRoot.cornerRadius
            width: fusionRoot.cornerRadius; height: fusionRoot.cornerRadius
            ShapePath {
                fillColor: fusionRoot.bgDark; strokeColor: "transparent"
                startX: fusionRoot.cornerRadius; startY: fusionRoot.cornerRadius
                PathArc { x: 0; y: 0; radiusX: fusionRoot.cornerRadius; radiusY: fusionRoot.cornerRadius; direction: PathArc.Clockwise; useLargeArc: false }
                PathLine { x: 0; y: fusionRoot.cornerRadius }
                PathLine { x: fusionRoot.cornerRadius; y: fusionRoot.cornerRadius }
            }
        }
    }

    PanelWindow {
        screen: fusionRoot.targetScreen
        anchors { top: true; bottom: true; right: true }
        implicitWidth: fusionRoot.frameThickness + fusionRoot.cornerRadius
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        Rectangle {
            anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.right: parent.right
            width: fusionRoot.frameThickness
            color: fusionRoot.bgDark
        }

        Shape {
            x: 0; y: fusionRoot.topBarHeight
            width: fusionRoot.cornerRadius; height: fusionRoot.cornerRadius
            ShapePath {
                fillColor: fusionRoot.bgDark; strokeColor: "transparent"
                startX: 0; startY: 0
                PathArc { x: fusionRoot.cornerRadius; y: fusionRoot.cornerRadius; radiusX: fusionRoot.cornerRadius; radiusY: fusionRoot.cornerRadius; direction: PathArc.Clockwise; useLargeArc: false }
                PathLine { x: fusionRoot.cornerRadius; y: 0 }
                PathLine { x: 0; y: 0 }
            }
        }

        Shape {
            x: 0; y: parent.height - fusionRoot.frameThickness - fusionRoot.cornerRadius
            width: fusionRoot.cornerRadius; height: fusionRoot.cornerRadius
            ShapePath {
                fillColor: fusionRoot.bgDark; strokeColor: "transparent"
                startX: fusionRoot.cornerRadius; startY: 0
                PathArc { x: 0; y: fusionRoot.cornerRadius; radiusX: fusionRoot.cornerRadius; radiusY: fusionRoot.cornerRadius; direction: PathArc.Clockwise; useLargeArc: false }
                PathLine { x: fusionRoot.cornerRadius; y: fusionRoot.cornerRadius }
                PathLine { x: fusionRoot.cornerRadius; y: 0 }
            }
        }
    }
}