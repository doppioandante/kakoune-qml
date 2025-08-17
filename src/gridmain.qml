import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Layouts 1.15
import Kakoune.ClientFactory 0.1

Window {
    visible: true
    id: mainWindow
    title: "Kakoune"

    width: 600
    height: 400

    NestedLayout {
        id: gridLayout
        anchors.fill: parent
        elemId: 0
    }

    Component.onCompleted: {
        let newTile = createNewTile(gridLayout)
        let newLayout = createSubLayout(gridLayout)
        let newTile1 = createNewTile(newLayout)
        let newLayout1 = createSubLayout(newLayout)
        let newTile2 = createNewTile(newLayout1)
        let newTile3 = createNewTile(newLayout1)
        ClientFactory.addNewClient(newTile)
        ClientFactory.addNewClient(newTile1)
        ClientFactory.addNewClient(newTile2)
        ClientFactory.addNewClient(newTile3)
    }

    function createNewTile(parentLayout) {
        let component = Qt.createComponent("FocusableTile.qml")
        let object = component.createObject(parentLayout, {
            fontFamily: "Monospace",
            visible: true,
            clip: true,
            focus: true,
            elemId: parentLayout.numPanes,
        });

        parentLayout.numPanes += 1
        object.Layout.fillWidth = true
        object.Layout.fillHeight = true
        object.Layout.minimumWidth = 200
        object.Layout.minimumHeight = 200

        object.Layout.preferredWidth = Qt.binding(function() {
            if (parentLayout.columns == -1) {
                return parentLayout.width / parentLayout.numPanes
            } else {
                return parentLayout.width
            }
        })
        object.Layout.preferredHeight = Qt.binding(function() {
            if (parentLayout.rows == -1) {
                return parentLayout.height / parentLayout.numPanes
            } else {
                return parentLayout.height
            }
        })
        object.Layout.row = Qt.binding(function() {
            if (parentLayout.rows == -1) {
                return object.elemId
            } else {
                return 0;
            }
        })
        object.Layout.column = Qt.binding(function() {
            if (parentLayout.columns == -1) {
                return object.elemId
            } else {
                return 0
            }
        })

        return object.tile
    }

    function createSubLayout(parentLayout) {
        let component = Qt.createComponent("NestedLayout.qml")
        let object = component.createObject(parentLayout, {
            elemId: parentLayout.numPanes,
            columns: 1,
            rows: -1,
        });
        object.Layout.fillWidth = true
        object.Layout.fillHeight = true
        object.Layout.minimumWidth = 200
        object.Layout.minimumHeight = 200

        object.Layout.preferredWidth = Qt.binding(function() {
            if (parentLayout.columns == -1) {
                return parentLayout.width / parentLayout.numPanes
            } else {
                return parentLayout.width
            }
        })
        object.Layout.preferredHeight = Qt.binding(function() {
            if (parentLayout.rows == -1) {
                return parentLayout.height / parentLayout.numPanes
            } else {
                return parentLayout.height
            }
        })
        object.Layout.row = Qt.binding(function() {
            if (parentLayout.rows == -1) {
                return object.elemId
            } else {
                return 0;
            }
        })
        object.Layout.column = Qt.binding(function() {
            if (parentLayout.columns == -1) {
                return object.elemId
            } else {
                return 0
            }
        })

        return object
    }

}

