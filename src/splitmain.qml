import QtQuick 2.7
import QtQuick.Window 2.2
 import QtQuick.Layouts 1.15

Window {
    visible: true
    id: mainWindow
    title: "Kakoune Split Window"

    width: 600
    height: 400

    RowLayout {
        FocusableTile {
          objectName: "kakounePaneLeft"; // needed by findChild() in main.cpp
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.minimumWidth: 50
          Layout.minimumHeight: 50
          Layout.preferredWidth: mainWindow.width / 2
          Layout.preferredHeight: mainWindow.height

          fontFamily: "Monospace";

          visible: true;
          focus: true;
        }

        FocusableTile {
            objectName: "kakounePaneRight"; // needed by findChild() in main.cpp
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 50
            Layout.minimumHeight: 50
            Layout.preferredWidth: mainWindow.width / 2
            Layout.preferredHeight: mainWindow.height

            fontFamily: "Monospace";

            visible: true;
            focus: true;
        }
    }
}
