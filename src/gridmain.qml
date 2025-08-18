import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.11
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
        let newTile1 = createNewTile(gridLayout)
        let newTile2 = createNewTile(gridLayout)
        ClientFactory.addNewClient(newTile)
        ClientFactory.addNewClient(newTile1)
        ClientFactory.addNewClient(newTile2)
    }

    function createNewTile(parentLayout) {
        let component = Qt.createComponent("FocusableTile.qml")
        let object = component.createObject(parentLayout, {
            fontFamily: "Monospace",
            visible: true,
            clip: true,
            focus: true,
            elemId: parentLayout.numPanes,
            'Layout.minimumWidth': 100,
            'Layout.minimumHeight': 100,
        });

        return parentLayout.addItemPreservingRatios(object).tile
    }

    function createSubLayout(parentLayout) {
        let component = Qt.createComponent("NestedLayout.qml")
        let object = component.createObject(parentLayout, {
            elemId: parentLayout.numPanes,
        });
        parentLayout.insertItem(parentLayout.numPanes, object)
        parentLayout.numPanes += 1

        return object
    }

}

