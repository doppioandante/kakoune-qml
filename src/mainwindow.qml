import QtQuick 2.7
import QtQuick.Window 2.2

Window {
    visible: true
    title: "boson"

    width: 600
    height: 400

    KakounePane {
      anchors.fill: parent;
      visible: true;
      focus: true;
    }
}
