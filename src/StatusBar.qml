import QtQuick 2.7
import "atom.js" as Atom

Rectangle {
    height: statusLine.height + statusLine.anchors.margins

    Text {
        id: statusLine
        textFormat: TextEdit.RichText
        font.family: "Monospace"

        anchors.left: parent.left
        anchors.margins: 5
    }

   Text {
        id: modeLine
        textFormat: TextEdit.RichText
        font.family: "Monospace"

        anchors.right: parent.right
        anchors.margins: 5
    }

    function render_mode_line(line, default_face) {
		return _render(modeLine, line, default_face)
    }

    function render_status_line(line, default_face) {
		return _render(statusLine, line, default_face)
    }

    function _render(id, line, default_face) {
        id.text = '<pre>' + Atom.renderAtoms(line, default_face) + '</pre>'
    }
}
