import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: frameOverlay
    
    // Cubre toda la pantalla
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    
    color: "transparent"
    
    // Evita reservar espacio exclusivo para que no desplace las ventanas de Hyprland
    exclusionMode: ExclusionMode.Ignore

    property int frameThickness: 12 // Grosor del marco lateral e inferior

    // Marco Izquierdo
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: frameOverlay.frameThickness
        color: root.frameColor
    }

    // Marco Derecho
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: frameOverlay.frameThickness
        color: root.frameColor
    }

    // Marco Inferior
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: frameOverlay.frameThickness
        color: root.frameColor
    }
}
