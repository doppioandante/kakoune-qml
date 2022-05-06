function escapeHtml(string) {
    var entityMap = {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': '&quot;',
        "'": '&#39;'
    };

    return String(string).replace(/[&<>"']/g, function (s) { // "
        return entityMap[s];
    });
}

function render(text, face) {
    text = escapeHtml(text);
    var attributes = face.attributes;

    var style = '';
    style += "color:'" + face.fg + "';";
    style += "background-color:'" + face.bg + "';";

    if (attributes.indexOf('underline') !== -1)
    {
        text = '<u>' + text + '</u>';
    }
    if (attributes.indexOf('bold') !== -1)
    {
        text = '<b>' + text + '</b>';
    }
    if (attributes.indexOf('italic') !== -1)
    {
        text = '<i>' + text + '</i>';
    }
    // TODO: exclusive, blink, dim, reverse
    return '<code style="' + style + '">' + text + '</code>';
}

function default_face(face, default_face) {
    var fg = face.fg === 'default' ? default_face.fg : parse_color(face.fg)
    var bg = face.bg === 'default' ? default_face.bg : parse_color(face.bg)

    return {fg: fg, bg: bg, attributes: face.attributes}
}

function parse_color(color) {
    if (color.startsWith('rgb:')) {
        return '#' + color.substring(4);
    } else if (color.startsWith('rgba:')) {
        return '#' + color.substring(5);
    }
    // named color
    return color;
}
