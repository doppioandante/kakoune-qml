import QtQuick 2.3
import "atom.js" as Atom
import "key_helpers.js" as KeyHelper

Item {
    id: item
    Rectangle {
        id: editorBg
        y: editor.y
        height: editor.height
        width: editor.width
    }
    Text {
        id: editor
        textFormat: TextEdit.RichText

        anchors.top: parent.top
        anchors.bottom: statusBar.top
    }

    Rectangle {
        id: statusBar
        height: statusLine.height + statusLine.anchors.margins
        width: parent.width

        anchors.bottom: parent.bottom

        Text {
            id: statusLine

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            anchors.margins: 5
        }

        Text {
            id: modeLine

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            anchors.margins: 5
        }
    }

    signal sendKey(string keys)

    Keys.onPressed: {
        item.sendKey(KeyHelper.convertKey(event.key, event.text));
        event.accepted = false;
    }

    function processRpc(line) {
try{
        var rpc = JSON.parse(line);
} catch(e) {
console.log(line);
}

        switch (rpc.method)
        {
            case 'draw':
              rpc_draw(rpc.params);
            break;

            case 'draw_status':
              rpc_draw_status(rpc.params);
            break;

            case 'refresh':
            break;
        }
    }

    function rpc_draw_status(params) {
        var status_line = params[0];
        var mode_line = params[1];
        var default_face = params[2];


        statusBar.color = default_face.bg == 'default' ? 'white' : default_face.bg;
        statusLine.font.family = "Monospace";
        statusLine.font.color = default_face.fg
        modeLine.font.family = "Monospace";
        modeLine.font.color = default_face.fg

        var text = '';
        for (var i = 0; i < status_line.length; i++) {
            text += Atom.render(status_line[i].contents, status_line[i].face, default_face);
        }
        statusLine.text = text

        text = ''
        for (var i = 0; i < mode_line.length; i++) {
            text += Atom.render(mode_line[i].contents, mode_line[i].face, default_face);
        }
        modeLine.text = text;
    }

    function rpc_draw(params) {
      var lines = params[0];
      var default_face = params[1];
      var text = '';

      for (var i = 0; i < lines.length; i++) {
         for (var j = 0; j < lines[i].length; j++) {
            text += Atom.render(lines[i][j].contents, lines[i][j].face, default_face);
         }
      }

      editorBg.color = default_face.bg == 'default' ? 'white' : default_face.bg;
      editor.font.family = "Monospace";
      editor.font.color = default_face.fg;
      console.log('drawing');

      editor.text = text;
    }

    function rpc_refresh(params) {
      if (params[0]) {
      }
    }

    signal sendResize(int x, int y)

    Connections {
        target: item
        onWidthChanged: doSendResize();
        onHeightChanged: doSendResize();

        function doSendResize() {
            item.sendResize(
                Math.floor(item.width/20),
                Math.floor(item.height/20)
            );
        }
    }
}

