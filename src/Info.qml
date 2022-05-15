import QtQuick 2.7
import QtQuick.Layouts 1.3
import "atom.js" as Atom

// FIXME: width binding loop
Rectangle {
   id: infoRect
   property alias title: titleLabel.text
   property alias text:  textBox.text
   property font fontFamily
   property real maxWidth

   width: textBox.width
   height: titleLabel.height + textBox.height

   border.width: 1.5

   Text {
      id: titleLabel
      textFormat: TextEdit.RichText
      font.family: fontFamily
      font.bold: true
      height: { text == '' ? 0 : implicitHeight }

      anchors.horizontalCenter: parent.horizontalCenter
   }

   Text {
      id: textBox
      textFormat: TextEdit.RichText
      font.family: fontFamily
      width: Math.min(paintedWidth, maxWidth)
      padding: 4

      // NOTE: this is not ideal, but other Wrap modes look worse when space is small
      wrapMode: Text.WrapAnywhere
      anchors.top: titleLabel.bottom
   }

   function render(title, text_lines, default_face) {
       let infoText = '<pre>'
       for (let i = 0; i < text_lines.length; i++) {
          infoText += Atom.renderAtoms(text_lines[i], default_face)
          infoText += '\n'
       }
       infoText += '</pre>'

       infoRect.color = default_face.bg
       infoRect.border.color = default_face.bg

       titleLabel.text = '<pre>' + Atom.renderAtoms(title, default_face) + '</pre>'
       textBox.text = infoText
   }
}
