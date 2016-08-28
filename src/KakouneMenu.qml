import QtQuick 2.7

GridView {
   id: menu
   focus: true

   property color fgColor
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
               anchors.left: parent.left
               id: menuEntryText
               text: entryText
               color: menu.fgColor

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
