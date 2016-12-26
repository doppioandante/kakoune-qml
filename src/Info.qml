import QtQuick 2.7
import QtQuick.Layouts 1.3

// FIXME: width binding loop
Rectangle {
   property alias title: titleLabel.text
   property alias text:  textBox.text
   property string fontFamily
   property color textColor
   property real maxWidth

   width: textBox.width
   height: titleLabel.height + textBox.height

   Text {
      id: titleLabel
      font.family: fontFamily
      font.bold: true
      color: textColor
      height: { text == '' ? 0 : implicitHeight }

      anchors.horizontalCenter: parent.horizontalCenter
   }

   Text {
      id: textBox
      font.family: fontFamily
      color: textColor
      width: Math.min(paintedWidth, maxWidth)

      wrapMode: Text.Wrap
      anchors.top: titleLabel.bottom
   }
}
