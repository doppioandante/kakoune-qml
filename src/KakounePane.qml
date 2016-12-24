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
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Rectangle {
       id: menuBgRectangle
       visible: false

       color: menu.bgColor
       clip: true

       Menu {
          id: menu
          cellHeight: menuEntryMetrics.height

          anchors.fill: parent
       }

       function computeHeight() {
          // get number of columns
          if (menu.cellWidth == 0) return 0

          var items_per_row = Math.floor(width / menu.cellWidth)
          var rows = Math.floor(menu.model.count / items_per_row)
          if (rows == 0 && menu.model.count > 0) {
             rows = 1
          }

          // limit to 10 rows
          return (rows > 10 ? 10 : rows) * menu.cellHeight
       }
    }

    StatusBar {
        id: statusBar
        width: parent.width
        anchors.bottom: parent.bottom
    }

    signal sendKey(string keys)

    Keys.onPressed: {
        var has_shift = true && (event.modifiers & Qt.ShiftModifier)
        var has_alt = true && (event.modifiers & Qt.AltModifier)
        var has_ctrl = true && (event.modifiers & Qt.ControlModifier)

        var kak_key = KeyHelper.convertKey(event.key, has_shift, has_alt, has_ctrl);
        if (kak_key !== undefined) {
            item.sendKey(kak_key)
        }
        event.accepted = false
    }

    function processRpc(line) {
        try{
            var rpc = JSON.parse(line)
        }
        catch(e) {
           // pass and hope the next line is valid
        }

        switch (rpc.method) {
            case 'draw':
              rpc_draw(rpc.params)
            break

            case 'draw_status':
              rpc_draw_status(rpc.params)
            break

            case 'refresh':
            break

            case 'menu_show':
              rpc_menu_show(rpc.params)
            break

            case 'menu_hide':
              rpc_menu_hide()
            break

            case 'menu_select':
              rpc_menu_select(rpc.params)
            break
        }
    }

    function rpc_draw_status(params) {
        var status_line = params[0]
        var mode_line = params[1]
        var default_face = params[2]
      
        // TODO: can be different from editor default face
        // TODO: remove face_or_default altogether, only use Atom.default_face
        default_face = face_or_default(default_face)

        statusBar.color = default_face.bg

        statusBar.render_status_line(status_line, default_face)
        statusBar.render_mode_line(mode_line, default_face)
    }

    function rpc_draw(params) {
      var lines = params[0]
      var default_face = params[1]
      // TODO: padding face

      default_face = face_or_default(default_face)
      item.defaultFg = default_face.fg
      item.defaultBg = default_face.bg

      var text = '<pre>'
      for (var i = 0; i < lines.length; i++) {
         for (var j = 0; j < lines[i].length; j++) {
            // HACK
            var c = lines[i][j].contents.replace('\n', ' ')
            text += Atom.render(c, face_or_default(lines[i][j].face))
         }
         text += Atom.render("\n", default_face)
      }
      text += '</pre>'

      editorBgRectangle.color = default_face.bg

      editor.text = text
    }

    function rpc_refresh(params) {
      if (params[0]) {
      }
    }

    function rpc_menu_show(params) {
       var items = params[0]
       var anchor = params[1]
       var fg = params[2]
       var bg = params[3]
       var style = params[4]

       var default_face = {
          fg: fg == 'default' ? 'black' : fg,
          bg: bg == 'default' ? 'white' : bg
       }

       if (style != 'prompt' && style != 'inline') return
       menu.model.clear()
       var maxWidth = 0

       for (var i = 0; i < items.length; i++) {
          var contents = ''
          var text = '<pre>'; 
          for (var j = 0; j < items[i].length; j++) {
             contents += items[i][j].contents
             text += Atom.render(items[i][j].contents, Atom.default_face(items[i][j].face, default_face))
          }
          text += '</pre>';
          menu.model.append({
             entryText: text
          })
          menuEntryMetrics.text = contents
          maxWidth = Math.max(maxWidth, menuEntryMetrics.advanceWidth)
       } 
       // FIXME
       menu.bgColor = 'white' //default_face.bg
       menu.entryWidth = maxWidth
       menu.rightPaddingWidth = 20 // FIXME with font metrics

       if (style == 'prompt') {
          menuBgRectangle.width = item.width
          menuBgRectangle.height = menuBgRectangle.computeHeight()
          menuBgRectangle.anchors.bottom = statusBar.top
          editorBgRectangle.anchors.bottom = menuBgRectangle.top
       }
       else {
          var x = (anchor.column + 1) * monospaceMetrics.averageCharacterWidth + editorBgRectangle.x
          if (x + menuBgRectangle.width > editorBgRectangle.width) {
             x = editorBgRectangle.width - menuBgRectangle.width

          }

          // TODO: rename maxWidth
          var maxEntryWidth = Math.max(x, item.width - x)
          
          var entryWidth = Math.min(menu.cellWidth, maxEntryWidth)
         
          menuBgRectangle.width = entryWidth
          menuBgRectangle.height = menuBgRectangle.computeHeight()

          var y = (anchor.line + 1) * monospaceMetrics.height + editorBgRectangle.y
          if (y + menuBgRectangle.height > editorBgRectangle.height) {
             y -= menuBgRectangle.height + monospaceMetrics.height
          }
          menuBgRectangle.x = x
          menuBgRectangle.y = y
       }

       menuBgRectangle.visible = true
    }

    function rpc_menu_hide() {
       menu.model.clear()
       menuBgRectangle.anchors.bottom = undefined
       editorBgRectangle.anchors.bottom = statusBar.top
       menuBgRectangle.visible = false
    }

    function rpc_menu_select(params) {
       var id = params[0]

       menu.currentIndex = id
       //console.log("---")
       //console.log(id)
       //console.log(menu.highlightItem)
       //console.log("---")
    }

    function face_or_default(face) {
       return Atom.default_face(face, {fg: item.defaultFg, bg: item.defaultBg})
    }

    signal sendResize(int x, int y)

    Connections {
        target: item
        onWidthChanged: doSendResize()
        onHeightChanged: doSendResize()

        function doSendResize() {
            item.sendResize(
                Math.floor(editor.height / monospaceMetrics.height),
                Math.floor(editorBgRectangle.width / monospaceMetrics.averageCharacterWidth)
            )
        }
    }

    FontMetrics {
        id: monospaceMetrics
        font.family: editor.font.family
    }

    TextMetrics {
        id: menuEntryMetrics
        text: "a"
    }
}

