import QtQuick 2.7
import "atom.js" as Atom
import "key_helpers.js" as KeyHelper

Item {
    id: item

    property color defaultBg: "#000000"
    property color defaultFg: "#FFFFFF"
    property string fontFamily
  
    EditorPane {
        id: editorBgRectangle
        width: parent.width
        height: { parent.height - statusBar.height }
        anchors.bottom: statusBar.top
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

          let items_per_row = Math.floor(width / menu.cellWidth)
          let rows = Math.floor(menu.model.count / items_per_row)
          if (rows == 0 && menu.model.count > 0) {
             rows = 1
          }

          // limit to 10 rows
          return (rows > 10 ? 10 : rows) * menu.cellHeight
       }
    }

    Info {
        id: infoBox
        fontFamily: item.fontFamily
        visible: false
    }

    StatusBar {
        id: statusBar
        fontFamily: item.fontFamily
        width: parent.width
        anchors.bottom: parent.bottom
    }

    signal sendKey(string keys)

    Keys.onPressed: {
        let has_shift = true && (event.modifiers & Qt.ShiftModifier)
        let has_alt = true && (event.modifiers & Qt.AltModifier)
        let has_ctrl = true && (event.modifiers & Qt.ControlModifier)

        let kak_key = KeyHelper.convertKey(event.key, has_shift, has_alt, has_ctrl);
        if (kak_key !== undefined) {
            item.sendKey(kak_key)
        }
        event.accepted = false
    }

    function processRpc(line) {
        let rpc = undefined

        try{
            rpc = JSON.parse(line)
        }
        catch(e) {
            // pass and hope the next line is valid
            return
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
        let status_line = params[0]
        let mode_line = params[1]
        let default_face = params[2]
      
        // TODO: can be different from editor default face
        // TODO: remove face_or_default altogether, only use Atom.default_face
        default_face = face_or_default(default_face)

        statusBar.color = default_face.bg

        statusBar.render_status_line(status_line, default_face)
        statusBar.render_mode_line(mode_line, default_face)
    }

    function rpc_draw(params) {
      let lines = params[0]
      let default_face = params[1]
      // TODO: padding face

      default_face = face_or_default(default_face)
      item.defaultFg = default_face.fg
      item.defaultBg = default_face.bg

      editorBgRectangle.draw(lines, default_face)
    }

    function rpc_menu_show(params) {
       // FIXME: menu doesn't react to resize
       let items = params[0]
       let anchor = params[1]
       let selected_face = params[2]
       let normal_face = params[3]
       let style = params[4]
       // TODO: can be different from editor
       normal_face = face_or_default(normal_face)
       selected_face = face_or_default(selected_face)

       menu.normalFace = normal_face
       menu.selectedFace = selected_face

       if (style !== 'prompt' && style !== 'inline') {
           return
       }

       menu.model.clear()
       let maxWidth = 0

       for (let i = 0; i < items.length; i++) {
          let contents = ''
          let text = '<pre>';
          for (let j = 0; j < items[i].length; j++) {
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

       if (style === 'prompt') {
          menu.rightPaddingWidth = 5 * fontMetrics.averageCharacterWidth

          menuBgRectangle.width = item.width
          menuBgRectangle.height = menuBgRectangle.computeHeight()
          menuBgRectangle.anchors.bottom = statusBar.top
       }
       else {
          menuBgRectangle.anchors.bottom = undefined
          let x = anchor.column * fontMetrics.averageCharacterWidth + editorBgRectangle.x
          if (x + menuBgRectangle.width > editorBgRectangle.width) {
             x = editorBgRectangle.width - menuBgRectangle.width
          }

          // TODO: rename maxWidth
          let maxEntryWidth = Math.max(x, editorBgRectangle.width - x)

          menu.rightPaddingWidth = fontMetrics.averageCharacterWidth;
          let entryWidth = Math.min(menu.cellWidth, maxEntryWidth)
         
          menuBgRectangle.width = entryWidth
          menuBgRectangle.height = menuBgRectangle.computeHeight()

          let y = (anchor.line + 1) * fontMetrics.height + editorBgRectangle.y
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
       menuBgRectangle.anchors.bottom = undefined
       menuBgRectangle.height = 0
       menuBgRectangle.x = 0
    }

    function rpc_menu_select(params) {
       // FIXME: expand bg color to whole selected item
       let id = params[0]

       // reset highlighting
       if (menu.currentIndex !== -1) {
           let element = menu.model.get(menu.currentIndex)
           element.entryText = Atom.render(element.rawText, menu.normalFace)
       }

       if (id === menu.count || id === -1) { // TODO: fix in kak?, input_handler.cc:822
          menu.currentIndex = -1
       }
       else {
           menu.currentIndex = id
           let element = menu.model.get(id)
           element.entryText = Atom.render(element.rawText, menu.selectedFace)
       }
    }

    function rpc_info_show(params) {
       let title = params[0]
       let text = params[1]
       let anchor = params[2]
       let face = params[3]
       let style = params[4]

        // must be called because on rpc_info_show could follow another one
        // without calling rpc_info_hide before
        rpc_info_hide({})

       face = face_or_default(face)
       infoBox.render(title, text, face)
       infoBox.maxWidth = Math.floor(item.width * 0.7)

       //if (infoBox.getCHeight() < infoBox.height) infoBox.height = infoBox.getCHeight();

       if (style === 'prompt') {
          infoBox.anchors.right = item.right
          infoBox.anchors.bottom = menuBgRectangle.top
       } else if (style.indexOf('inline') === 0) {
          let x = (anchor.column) * fontMetrics.averageCharacterWidth + editorBgRectangle.x
          if (x + infoBox.width > editorBgRectangle.width) {
             x = editorBgRectangle.width - infoBox.width
          }
          let lineInc = (style === 'inlineAbove') ? -1 : 1;
          let y = (anchor.line + lineInc) * fontMetrics.height + editorBgRectangle.y
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
       infoBox.anchors.top = undefined
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
        function onWidthChanged() {
            doSendResize()
        }
        function onHeightChanged() {
            doSendResize()
        }

        function doSendResize() {
            item.sendResize(
                Math.floor(editorBgRectangle.height / fontMetrics.height),
                Math.round(editorBgRectangle.width / fontMetrics.averageCharacterWidth) + 2,
            )
        }
    }

    FontMetrics {
        id: fontMetrics
        font.family: item.fontFamily
    }

    TextMetrics {
        id: textMetrics
        font.family: item.fontFamily
    }
}

