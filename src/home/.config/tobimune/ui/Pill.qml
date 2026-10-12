import QtQuick

Rectangle {
    id: rootPill
    default property alias content: row.children 
    
    height: 44 
    color: "#000000" 
    radius: 4 
    border.width: 0 
    width: row.implicitWidth + 16

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 12 // Ajustado a tu valor
        
        Component.onCompleted: {
            for (var i = 0; i < children.length; ++i) {
                if (children[i].anchors) {
                    children[i].anchors.verticalCenter = row.verticalCenter
                }
            }
        }
    }
}
