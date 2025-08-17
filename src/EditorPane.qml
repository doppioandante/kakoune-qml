import QtQuick 2.7
import QtQuick.Controls 2.7
import "atom.js" as Atom

Rectangle {
    id: editorPane
    property string fontFamily
    property alias text: editor.text

    property int cursorLine: 0
    property int bufferLines: 100
    property int visibleLines: 20
    property bool sublineScroll: true

    Text {
        id: editor
        textFormat: TextEdit.RichText
        font.family: editorPane.fontFamily

        anchors.fill: parent
        anchors.verticalCenter: parent.verticalCenter

        property int pixelScrollAmount: 0

        /*ScrollBar {
            id: editorScrollbar
            hoverEnabled: true
            active: hovered || pressed
            orientation: Qt.Vertical
            size: editorPane.visibleLines / editorPane.bufferLines
            position: 1 - (editorPane.cursorLine+1)/editorPane.visibleLines
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }*/
    }

    MouseArea {
        anchors.fill: parent
        onWheel: (evt) => {
            let y_delta = evt.angleDelta.y/120 * 4
            let pixelScrollAmount = editor.pixelScrollAmount
            let discreteAmount = 0;

            pixelScrollAmount += y_delta * 8
            if (editorPane.sublineScroll) {
                discreteAmount = Math.floor(pixelScrollAmount / fontMetrics.height);
                pixelScrollAmount -= discreteAmount * fontMetrics.height;

                editor.anchors.topMargin = pixelScrollAmount
                editor.pixelScrollAmount = pixelScrollAmount
            } else {
                discreteAmount = Math.floor(pixelScrollAmount/fontMetrics.height);
            }
            let view_key = discreteAmount > 0 ? "k" : "j"
            if (discreteAmount != 0) {
                item.sendKeys(Math.abs(discreteAmount).toString() + "v" + view_key)
                evt.accepted = true
            }
        }
    }

    function draw(lines, default_face) {
        // TODO: padding face
        let text = '<pre>'
        let max_width = Math.floor(editor.width / fontMetrics.averageCharacterWidth)
        for (var i = 0; i < lines.length; i++) {
            let trailing_atom = lines[i][lines[i].length - 1]
            trailing_atom.contents = trailing_atom.contents.replace(
                '\n', ' ');
            lines[i][lines[i].length - 1] = trailing_atom
                
            text += Atom.renderAtoms(lines[i], default_face)
            text += ' \n'
        }
        text += '</pre>'

        editorPane.color = default_face.bg

        editor.text = text
    }
}
