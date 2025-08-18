import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.11

GridLayout {
    id: splitview
    property int orientation: Qt.Horizontal
    property int numPanes: 0
    required property int elemId
    property var weights: []
    property list<Item> items
    property list<NestedHandle> handles

    property int prevResizedId: -1
    property int nextResizedId: -1

    rows: (orientation == Qt.Horizontal) ? -1 : 1
    columns: (orientation == Qt.Vertical) ? 1 : -1

    HoverHandler {
        id: moveHover
        enabled: false

        onPointChanged: {
            let prevItem = splitview.items[splitview.prevResizedId]
            let nextItem = splitview.items[splitview.nextResizedId]
            let relativeP = splitview.mapToItem(prevItem, moveHover.point.position)

            let diff = prevItem.Layout.preferredWidth - relativeP.x
            let maxPrevDiff = prevItem.Layout.preferredWidth - prevItem.Layout.minimumWidth
            let maxNextDiff = nextItem.Layout.preferredWidth - nextItem.Layout.minimumWidth
            diff = Math.min(diff, maxPrevDiff)
            diff = Math.max(diff, -maxNextDiff)
            prevItem.Layout.preferredWidth -= diff
            nextItem.Layout.preferredWidth += diff

            console.log(
                splitview.items[0].Layout.preferredWidth,
                splitview.items[1].Layout.preferredWidth,
                splitview.items[2].Layout.preferredWidth,
            );
        }
    }

    onWidthChanged: {
        assignAllPreferredSizes()
    }

    function addItemPreservingRatios(item) {
        item.Layout.fillHeight = true
        item.Layout.fillWidth = true
        item.Layout.column = 2*splitview.numPanes

        splitview.items.push(item)

        let newweight = 1 / (splitview.numPanes + 1)

        for (let i = 0; i < splitview.numPanes; i++) {
            splitview.weights[i] *= (1 - newweight)
        }
        splitview.weights.push(newweight)

        splitview.numPanes += 1

        if (splitview.numPanes >= 2)
            addHandle()

        return item;
    }

    function addHandle() {
        let col = 2*(splitview.numPanes-1)-1 
        let component = Qt.createComponent("NestedHandle.qml")
        let object = component.createObject(splitview, {
            color: 'orange',
            'Layout.preferredWidth': 10,
            'Layout.fillWidth': true,
            'Layout.fillHeight': true,
            'Layout.column': col,
        });
        splitview.handles.push(object)
        object.resizeHandleStateChange.connect(handleChildResizeTrigger)
    }

    function handleChildResizeTrigger(col, state) {
        moveHover.enabled = state

        if (state) {
            splitview.prevResizedId = (col-1)/2
            splitview.nextResizedId = (col-1)/2 + 1
            console.log(splitview.prevResizedId)
        } else {
            splitview.prevResizedId = -1
            splitview.nextResizedId = -1
        }
    }

    function assignAllPreferredSizes() {
        for (let i = 0; i < splitview.numPanes; i++) {
            splitview.items[i].Layout.preferredWidth = splitview.width * splitview.weights[i]
        }
    }
}

