import QtQuick 2.7

GridView {
   // remove id, move delegate component in another file?
   id: menu
   focus: true

   property var normalFace
   property var selectedFace

   property int rightPaddingWidth
   property int entryWidth

   cellWidth: {
      // margin for space
      return entryWidth + rightPaddingWidth;
   }

   currentIndex: -1
   highlightFollowsCurrentItem: true
   //keyNavigationEnabled: false

   model: ListModel {}

   delegate: Component {
      id: component
      Rectangle {
           width:  menu.cellWidth; 
           height: menu.cellHeight
           color:  menu.normalFace.bg

           Text {
               id: menuEntryText
               anchors.left: parent.left

               textFormat: TextEdit.RichText
               font.family: "Monospace"
               text: entryText // created dynamically by rpc_menu_show

               width: menu.entryWidth
           }

           MouseArea {
               anchors.fill: parent
               hoverEnabled: true
               onClicked: {
                  menu.currentIndex = index;
                  mouse.accepted = false;
               }

               /*onEntered: {
                  menu.highlightFollowsCurrentItem = false;
               }
               onPositionChanged: {
               
               }
               onExited: {
                  menu.highlightFollowsCurrentItem = true;
               }*/
               
           }
       }
   }

   onCurrentItemChanged: { /*console.log(model.get(menu.currentIndex).name + ' selected')*/ }
}
