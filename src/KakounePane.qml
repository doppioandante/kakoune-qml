import QtQuick 2.7
import "atom.js" as Atom
import "key_helpers.js" as KeyHelper

Item {
    id: item

    property color defaultBg: "#FFFFCC"
    property color defaultFg: "#000000"
  

    Rectangle {
        id: editorBgRectangle
        width: parent.width
        height: { parent.height - statusBar.height }
        anchors.bottom: statusBar.top
        color: defaultBg


        Text {
            id: editor
            textFormat: TextEdit.RichText
            font.family: "Monospace"

            anchors.fill: parent
            // TODO ??
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Rectangle {
        id: statusBar
        height: statusLine.height + statusLine.anchors.margins
        width: parent.width

        anchors.bottom: parent.bottom

        Text {
            id: statusLine
            textFormat: TextEdit.RichText
            font.family: "Monospace";

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            anchors.margins: 5
        }

        Text {
            id: modeLine
            textFormat: TextEdit.RichText
            font.family: "Monospace";

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            anchors.margins: 5
        }
    }

    signal sendKey(string keys)

    Keys.onPressed: {
        var has_shift = true && (event.modifiers & Qt.ShiftModifier);
        var has_alt = true && (event.modifiers & Qt.AltModifier);
        var has_ctrl = true && (event.modifiers & Qt.ControlModifier);

        if (event.text != '') {
            item.sendKey(KeyHelper.convertKey(event.key, event.text, has_shift, has_alt, has_ctrl));
        }
        event.accepted = false;
    }

    function processRpc(line) {
        try{
            var rpc = JSON.parse(line);
        }
        catch(e) {
           // pass and hope the next line is valid
        }

        switch (rpc.method) {
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
        
        default_face = face_or_default(default_face);

        // TODO: needed?
        statusBar.color = default_face.bg;

        statusLine.font.color = default_face.fg;
        modeLine.font.color = default_face.fg

        var text = '<pre>';
        for (var i = 0; i < status_line.length; i++) {
            text += Atom.render(status_line[i].contents, face_or_default(status_line[i].face));
        }
        statusLine.text = text + '</pre>';

        text = '<pre>'
        for (var i = 0; i < mode_line.length; i++) {
            text += Atom.render(mode_line[i].contents, face_or_default(mode_line[i].face));
        }
        modeLine.text = text + '</pre>';
    }

    function rpc_draw(params) {
      var lines = params[0];
      var default_face = params[1];
      // TODO: padding face

      default_face = face_or_default(default_face);

      //console.log(JSON.stringify(lines, null, 2));

      var text = '<pre>';
      for (var i = 0; i < lines.length; i++) {
         for (var j = 0; j < lines[i].length; j++) {
            text += Atom.render(lines[i][j].contents, face_or_default(lines[i][j].face));
         }
      }
      text += '</pre>';

      editorBgRectangle.color = default_face.bg;
      //editor.font.color = default_face.fg;

      editor.text = text;
    }

    function rpc_refresh(params) {
      if (params[0]) {
      }
    }

    function face_or_default(face) {
       var fg = face.fg == 'default' ? item.defaultFg : face.fg;
       var bg = face.bg == 'default' ? item.defaultBg : face.bg;

       return {fg: fg, bg: bg, attributes: face.attributes};
    }

    signal sendResize(int x, int y)

    Connections {
        target: item
        onWidthChanged: doSendResize();
        onHeightChanged: doSendResize();

        function doSendResize() {
            item.sendResize(
                Math.floor(Math.floor(editor.height / monospaceMetrics.height)),
                Math.floor(Math.floor(item.width  / monospaceMetrics.averageCharacterWidth))
            );
        }
    }

    FontMetrics {
        id: monospaceMetrics
        font.family: editor.font.family
    }
}

