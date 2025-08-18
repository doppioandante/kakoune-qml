import QtQuick 2.12
import QtQuick.Layouts 1.11

Rectangle {
    id: handle
    anchors.margins: 0
    border.width: 0

    signal resizeHandleStateChange(int col, bool state)
    signal resizeHandleMove(int col, real x, real y)

    PointHandler {
        id: clickHover
        acceptedButtons: Qt.LeftButton

        onActiveChanged: {
            handle.resizeHandleStateChange(handle.Layout.column, active)
        }
    }
}

