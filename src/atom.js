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

function render(text, face) {
    text = escapeHtml(text);
    var attributes = face.attributes;

    var style = '';
    style += "color:'" + face.fg + "';";
    style += "background-color:'" + face.bg + "';";

    if (attributes.indexOf('underline') != -1)
    {
        text = '<u>' + text + '</u>';
    }
    if (attributes.indexOf('bold') != -1)
    {
        text = '<b>' + text + '</b>';
    }
    if (attributes.indexOf('italic') != -1)
    {
        text = '<i>' + text + '</i>';
    }
    // TODO: exclusive, blink, dim, reverse
    return '<code style="' + style + '">' + text + '</code>';
}

