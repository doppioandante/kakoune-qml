'use strict';

var special_table = {};

special_table[Qt.Key_Return] = 'ret';
special_table[Qt.Key_Space] = 'space';
special_table[Qt.Key_Tab] = 'tab';
special_table[Qt.Key_BracketLeft] = 'lt';
special_table[Qt.Key_BracketRight] = 'gt';
special_table[Qt.Key_Backspace] = 'backspace';
special_table[Qt.Key_Escape] = 'esc';
special_table[Qt.Key_Up] = 'up';
special_table[Qt.Key_Down] = 'down';
special_table[Qt.Key_Left] = 'left';
special_table[Qt.Key_Right] = 'right';
special_table[Qt.Key_PageUp] = 'pageup';
special_table[Qt.Key_PageDown] = 'pagedown';
special_table[Qt.Key_Home] = 'home';
special_table[Qt.Key_End] = 'end';
special_table[Qt.Key_Backtab] = 'backtab';
special_table[Qt.Key_Delete] = 'del';


function convertKey(code, text) {
    if (special_table.hasOwnProperty(code))
    {
        return '<' + special_table[code] + '>';
    }

    return text;
}
