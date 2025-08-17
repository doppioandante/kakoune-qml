import QtQuick 2.0
import QtQuick.Controls 2.15

FocusScope {
    id: scope

    property alias tile: tile
    property alias fontFamily: tile.fontFamily
    property alias objectName: tile.objectName
    required property int elemId
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
