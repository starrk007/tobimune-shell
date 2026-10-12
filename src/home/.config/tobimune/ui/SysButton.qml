import QtQuick

Rectangle {
    id: btnRoot
    property string icon: ""
    property string textData: ""
    
    property color accentColor: root.accentColor 
    property bool alwaysInverted: false 
    
    // Nueva propiedad para controlar el tamaño de los PNG/SVG
    property int iconSize: 36 

    signal clicked()

    width: btnRow.implicitWidth + 16
    height: 26
    radius: 4
    
    readonly property bool isImageIcon: icon.endsWith(".svg") || icon.endsWith(".png")

    color: (alwaysInverted || mouseArea.containsMouse) ? accentColor : "transparent"
    Behavior on color { ColorAnimation { duration: 150 } }

    Row {
        id: btnRow
        anchors.centerIn: parent
        spacing: 6
        
        Text { 
            visible: !btnRoot.isImageIcon && btnRoot.icon !== ""
            text: btnRoot.icon
            color: (btnRoot.alwaysInverted || mouseArea.containsMouse) ? "#000000" : btnRoot.accentColor
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 15
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Image {
            visible: btnRoot.isImageIcon
            source: btnRoot.isImageIcon ? btnRoot.icon : ""
            // Usa la nueva propiedad de tamaño
            width: btnRoot.iconSize
            height: btnRoot.iconSize
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            mipmap: true
        }
        
        Text { 
            text: btnRoot.textData
            visible: btnRoot.textData !== ""
            color: (btnRoot.alwaysInverted || mouseArea.containsMouse) ? "#000000" : btnRoot.accentColor
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: btnRoot.clicked()
    }
}

