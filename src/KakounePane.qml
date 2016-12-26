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
       height: 0
       anchors.bottom: statusBar.top

       clip: true

       Menu {
          id: menu
          cellHeight: textMetrics.height

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


    Info {
        id: infoBox
        fontFamily: editor.font.family
        visible: false
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
            case 'info_show':
               rpc_info_show(rpc.params)
            break
            case 'info_hide':
               rpc_info_hide(rpc.params)
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

    function rpc_menu_show(params) {
       // FIXME: menu doesn't react to resize
       var items = params[0]
       var anchor = params[1]
       var selected_face = params[2]
       var normal_face = params[3]
       var style = params[4]

       // TODO: can be different from editor
       normal_face = face_or_default(normal_face)
       selected_face = face_or_default(selected_face)

       menu.normalFace = normal_face
       menu.selectedFace = selected_face

       if (style != 'prompt' && style != 'inline') {
           return
       }

       menu.model.clear()
       var maxWidth = 0

       for (var i = 0; i < items.length; i++) {
          var contents = ''
          var text = '<pre>'; 
          for (var j = 0; j < items[i].length; j++) {
             contents += items[i][j].contents
             text += Atom.render(items[i][j].contents, Atom.default_face(items[i][j].face, normal_face))
          }
          text += '</pre>';
          menu.model.append({
             rawText: contents,
             entryText: text // TODO: change name
          })
          textMetrics.text = contents
          maxWidth = Math.max(maxWidth, textMetrics.width)
       } 
       menu.entryWidth = maxWidth

       if (style == 'prompt') {
          menu.rightPaddingWidth = 5 * fontMetrics.averageCharacterWidth

          menuBgRectangle.width = item.width
          menuBgRectangle.height = menuBgRectangle.computeHeight()
          menuBgRectangle.anchors.bottom = statusBar.top
          editorBgRectangle.anchors.bottom = menuBgRectangle.top
       }
       else {
          var x = (anchor.column + 1) * fontMetrics.averageCharacterWidth + editorBgRectangle.x
          if (x + menuBgRectangle.width > editorBgRectangle.width) {
             x = editorBgRectangle.width - menuBgRectangle.width
          }

          // TODO: rename maxWidth
          var maxEntryWidth = Math.max(x, editorBgRectangle.width - x)

          menu.rightPaddingWidth = fontMetrics.averageCharacterWidth;
          var entryWidth = Math.min(menu.cellWidth, maxEntryWidth)
         
          menuBgRectangle.width = entryWidth
          menuBgRectangle.height = menuBgRectangle.computeHeight()

          var y = (anchor.line + 1) * fontMetrics.height + editorBgRectangle.y
          if (y + menuBgRectangle.height > editorBgRectangle.height) {
             y -= menuBgRectangle.height + fontMetrics.height
          }
          menuBgRectangle.x = x
          menuBgRectangle.y = y
       }

       menuBgRectangle.color = normal_face.bg
       menuBgRectangle.visible = true
    }

    function rpc_menu_hide() {
       menuBgRectangle.visible = false
       menuBgRectangle.anchors.bottom = statusBar.top
       editorBgRectangle.anchors.bottom = statusBar.top
       menuBgRectangle.height = 0
       menuBgRectangle.x = 0
    }

    function rpc_menu_select(params) {
       // FIXME: expand bg color to whole selected item
       var id = params[0]

       // reset highlighting
       if (menu.currentIndex !== -1) {
           var element = menu.model.get(menu.currentIndex)
           element.entryText = Atom.render(element.rawText, menu.normalFace)
       }

       if (id === menu.count || id === -1) { // TODO: fix in kak?, input_handler.cc:822
          menu.currentIndex = -1
       }
       else {
           menu.currentIndex = id
           var element = menu.model.get(id)
           element.entryText = Atom.render(element.rawText, menu.selectedFace)
       }
    }

    function rpc_info_show(params) {
       var title = params[0]
       var text = params[1]
       var anchor = params[2]
       var face = params[3]
       var style = params[4]

       face = face_or_default(face)
       // must be called because on rpc_info_show could follow another one
       // without calling rpc_info_hide before
       rpc_info_hide({})

       infoBox.title = title
       infoBox.text = text
       infoBox.color = face.bg
       infoBox.textColor = face.fg
       infoBox.maxWidth = item.width

       if (style == 'prompt') {
          infoBox.anchors.right = item.right
          infoBox.anchors.bottom = menuBgRectangle.top
       } else if (style.indexOf('inline') == 0) {
          var x = (anchor.column) * fontMetrics.averageCharacterWidth + editorBgRectangle.x
          if (x + infoBox.width > editorBgRectangle.width) {
             x = editorBgRectangle.width - infoBox.width
          }
          var lineInc = (style == 'inlineAbove') ? -1 : 1;
          var y = (anchor.line + lineInc) * fontMetrics.height + editorBgRectangle.y
          if (y + infoBox.height > editorBgRectangle.height) {
             y -= infoBox.height + fontMetrics.height
          }

          infoBox.x = x
          infoBox.y = y
       }
       infoBox.visible = true
    }

    function rpc_info_hide(params) {
       infoBox.visible = false
       infoBox.anchors.bottom = undefined
       infoBox.anchors.right = undefined
       infoBox.anchors.margins = 0
       infoBox.text = ''
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
                Math.floor(editor.height / fontMetrics.height),
                Math.floor(editorBgRectangle.width / fontMetrics.averageCharacterWidth)
            )
        }
    }

    FontMetrics {
        id: fontMetrics
        font.family: editor.font.family
    }

    TextMetrics {
        id: textMetrics
        font.family: editor.font.family
    }
}

