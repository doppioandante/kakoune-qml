import QtQuick 2.7
import QtQuick.Window 2.2

Window {
    visible: true
    title: "Kakoune"

    width: 600
    height: 400

    Tile {
      objectName: "kakounePane"; // needed by findChild() in main.cpp

      fontFamily: "Monospace";

      anchors.fill: parent;
      visible: true;
      focus: true;
    }
}
