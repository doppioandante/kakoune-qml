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

    function prefSize(item) {
        return (orientation == Qt.Horizontal) ? item.Layout.preferredWidth : item.Layout.preferredHeight
    }

    function assingPrefSize(item, size) {
        if (orientation == Qt.Horizontal) {
             item.Layout.preferredWidth = size
        } else {
            item.Layout.preferredHeight = size
        }
    }

    function minSize(item) {
        return (orientation == Qt.Horizontal) ? item.Layout.minimumWidth : item.Layout.minimumHeight
    }

    HoverHandler {
        id: moveHover
        enabled: false

        onPointChanged: {
            let prevItem = splitview.items[splitview.prevResizedId]
            let nextItem = splitview.items[splitview.nextResizedId]
            let relativeP = splitview.mapToItem(prevItem, moveHover.point.position)
            let relativeCoord = (orientation == Qt.Horizontal) ? relativeP.x : relativeP.y

            let diff = prefSize(prevItem) - relativeCoord
            let maxPrevDiff = prefSize(prevItem) - minSize(prevItem)
            let maxNextDiff = prefSize(nextItem) - minSize(nextItem)
            diff = Math.min(diff, maxPrevDiff)
            diff = Math.max(diff, -maxNextDiff)
            assingPrefSize(prevItem, prefSize(prevItem) - diff)
            assingPrefSize(nextItem, prefSize(nextItem) + diff)
        }
    }

    onWidthChanged: {
        assignAllPreferredSizes()
    }

    function addItemPreservingRatios(item) {
        item.Layout.fillHeight = true
        item.Layout.fillWidth = true
        item.Layout.column = Qt.binding(function() {
            return (splitview.orientation == Qt.Horizontal)
                 ? 2*item.elemId : 0
        })
        item.Layout.row = Qt.binding(function() {
            return (splitview.orientation == Qt.Horizontal)
                 ? 0 : 2*item.elemId
        })

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
        let component = Qt.createComponent("NestedHandle.qml")
        let pos = 2*(splitview.numPanes-1)-1 
        let object = component.createObject(splitview, {
            color: 'orange',
            gridPos: pos,
            'Layout.preferredWidth': Qt.binding(function() {
                if (splitview.orientation == Qt.Horizontal)
                    return 10;
                else
                    return -1;
            }),
            'Layout.preferredHeight': Qt.binding(function() {
                if (splitview.orientation == Qt.Vertical)
                    return 10;
                else
                    return -1;
            }),
            'Layout.fillWidth': true,
            'Layout.fillHeight': true,
        });

        object.Layout.column = Qt.binding(function() {
            return (splitview.orientation == Qt.Horizontal)
                 ? pos : 0
        })
        object.Layout.row = Qt.binding(function() {
            return (splitview.orientation == Qt.Horizontal)
                 ? 0 : pos
        })
        splitview.handles.push(object)
        object.resizeHandleStateChange.connect(handleChildResizeTrigger)
    }

    function handleChildResizeTrigger(pos, state) {
        moveHover.enabled = state

        if (state) {
            splitview.prevResizedId = (pos-1)/2
            splitview.nextResizedId = (pos-1)/2 + 1
        } else {
            splitview.prevResizedId = -1
            splitview.nextResizedId = -1
            recomputeWeights()
        }
    }

    function assignAllPreferredSizes() {
        let leadingSize = (splitview.orientation == Qt.Horizontal) ? splitview.width : splitview.height
        for (let i = 0; i < splitview.numPanes; i++) {
            assingPrefSize(splitview.items[i], leadingSize * splitview.weights[i])
        }
    }

    function recomputeWeights() {
        let leadingSize = (splitview.orientation == Qt.Horizontal) ? splitview.width : splitview.height
        for (let i = 0; i < splitview.numPanes; i++) {
            splitview.weights[i] = prefSize(splitview.items[i]) / leadingSize
        }
    }
}

