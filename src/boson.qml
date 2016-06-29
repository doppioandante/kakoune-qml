import QtQuick 2.3
import QtQuick.Window 2.2

Window {
    visible: true
    title: "boson"

    width: 300
    height: 300

    KakounePane {
      anchors.fill: parent;
      visible: true;
      focus: true;
    }
}
