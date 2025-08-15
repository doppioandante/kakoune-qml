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
        let max_width = Math.floor(editor.width / fontMetrics.averageCharacterWidth)
        for (var i = 0; i < lines.length; i++) {
            let trailing_atom = lines[i][lines[i].length - 1]
            trailing_atom.contents = trailing_atom.contents.replace(
                '\n', ' ');
            lines[i][lines[i].length - 1] = trailing_atom
                
            text += Atom.renderAtoms(lines[i], default_face)
            text += ' \n'
            //console.log('line', i)
            //console.log(text)
        }
        text += '</pre>'

        editorPane.color = default_face.bg

        editor.text = text
    }
}
