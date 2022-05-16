import QtQuick 2.7
import "atom.js" as Atom

Rectangle {
    id: editorPane
    property string fontFamily
    property alias text: editor.text

    Text {
        id: editor
        textFormat: TextEdit.RichText
        font.family: editorPane.fontFamily

        anchors.fill: parent
        anchors.verticalCenter: parent.verticalCenter
    }

    function draw(lines, default_face) {
        // TODO: padding face
        let text = '<pre>'
        for (var i = 0; i < lines.length; i++) {
            text += Atom.renderAtoms(lines[i], default_face)
        }
        text += '</pre>'

        editorPane.color = default_face.bg

        editor.text = text
    }
}
