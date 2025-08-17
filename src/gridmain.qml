import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.13
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
            "SplitView.minimumWidth": 100,
            "SplitView.minimumHeight": 100,
            "SplitView.preferredWidth": Qt.binding(function() { 
                return parentLayout.width / (parentLayout.numPanes+1);
            }),
            "SplitView.preferredHeight": parentLayout.height,
            "SplitView.fillHeight": true,
            "SplitView.fillWidth": true,
        });

        parentLayout.addItem(parentLayout.numPanes, object)
        parentLayout.numPanes += 1

        return object.tile
    }

    function createSubLayout(parentLayout) {
        let component = Qt.createComponent("NestedLayout.qml")
        let object = component.createObject(parentLayout, {
            elemId: parentLayout.numPanes,
            orientation: Qt.Vertical,
            "SplitView.minimumWidth": 100,
            "SplitView.minimumHeight": 100,
            "SplitView.preferredWidth": 1,
            "SplitView.preferredHeight": 1,
            "SplitView.fillHeight": true,
            "SplitView.fillWidth": true,
        });
        parentLayout.addItem(parentLayout.numPanes, object)
        parentLayout.numPanes += 1

        return object
    }

}

