"use strict";
function escapeHtml(string) {
    var entityMap = {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': '&quot;',
        "'": '&#39;'
    };

    return String(string).replace(/[&<>"']/g, function (s) {
        return entityMap[s];
    });
}

function render(text, face, default_face) {
    text = escapeHtml(text).replace(' ', '&nbsp;').replace("\n", '<br/>');

    var style = '';
    if (face.fg !== default_face.fg) {
        style += "color: '" + face.fg + "';";
    }
    if (face.bg !== default_face.bg) {
        style += "background-color: '" + face.bf + "';";
    }

    if (style !== '') {
        text = '<span style="' + style + ' white-space: pre;">' + text + '</span>';
    }
    return text;
}

