import QtQuick 2.0

FocusScope {
    id: scope

    property alias fontFamily: tile.fontFamily
    property alias objectName: tile.objectName
    x: tile.x; y: tile.y
    width: tile.width; height: tile.heigh

    Tile {
        id: tile
        focus: true
        anchors.fill: parent;
    }
    MouseArea {
        anchors.fill: parent;
        onClicked: {
            scope.focus = true
        }
    }
}
