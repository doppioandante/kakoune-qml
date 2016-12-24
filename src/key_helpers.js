'use strict';

var special_table = {};
special_table[Qt.Key_Return]       = 'ret';
special_table[Qt.Key_Space]        = 'space';
special_table[Qt.Key_Tab]          = 'tab';
special_table[Qt.Key_BracketLeft]  = 'lt';
special_table[Qt.Key_BracketRight] = 'gt';
special_table[Qt.Key_Backspace]    = 'backspace';
special_table[Qt.Key_Escape]       = 'esc';
special_table[Qt.Key_Up]           = 'up';
special_table[Qt.Key_Down]         = 'down';
special_table[Qt.Key_Left]         = 'left';
special_table[Qt.Key_Right]        = 'right';
special_table[Qt.Key_PageUp]       = 'pageup';
special_table[Qt.Key_PageDown]     = 'pagedown';
special_table[Qt.Key_Home]         = 'home';
special_table[Qt.Key_End]          = 'end';
special_table[Qt.Key_Backtab]      = 'backtab';
special_table[Qt.Key_Delete]       = 'del';


function convertKey(code, has_shift, has_alt, has_ctrl) {
    var found_lookup = special_table.hasOwnProperty(code);
    var has_brackets = found_lookup || has_alt || has_ctrl;

    var key = undefined;

    if (found_lookup || code <= 0x0ff) {
        if (found_lookup) {
            key = special_table[code];
        } else {
            var key = String.fromCharCode(code)

            if (!has_shift) {
                key = key.toLowerCase();
            }
        }
        if (has_ctrl) {
            key = 'c-' + key
        }
        else if (has_alt) {
            key = 'a-' + key;
        }

        if (has_brackets)
        	key = '<' + key + '>';
    }

    return key;
}
