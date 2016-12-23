import QtQuick 2.7

GridView {
   // remove id, move delegate component in another file?
   id: menu
   focus: true

   property color bgColor
   property int hintCellWidth

   property int entryWidth 

   entryWidth: {
      return ((hintCellWidth < 100) ? hintCellWidth : 100);
   }

   cellWidth: {
      // margin for space
      return entryWidth + 10;
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
           color:  menu.bgColor
           opacity: 0.8

           clip: true

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

   highlight: Rectangle {
      width: menu.cellWidth;
      height: menu.cellHeight
      color: "lightsteelblue";
      x: menu.currentItem.x
      y: menu.currentItem.y
   }

   onCurrentItemChanged: { /*console.log(model.get(menu.currentIndex).name + ' selected')*/ }
}
