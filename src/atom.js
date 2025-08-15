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
    let attributes = face.attributes;

    let  style = '';
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

function renderAtoms(atoms, default_face) {
    let result = ''
    for (let i = 0; i < atoms.length; i++) {
        result += Atom.render(atoms[i].contents, Atom.default_face(atoms[i].face, default_face))
        if(atoms[i].contents.indexOf('\n') !== -1)
            console.log('!!!!', atoms[i].contents.indexOf('\n'))
    }
    return result
}

function default_face(face, default_face) {
    let fg = face.fg === 'default' ? default_face.fg : parse_color(face.fg)
    let bg = face.bg === 'default' ? default_face.bg : parse_color(face.bg)

    return {fg: fg, bg: bg, attributes: face.attributes}
}

function parse_color(color) {
    if (color.startsWith('rgb:')) {
        return '#' + color.substring(4)
    } else if (color.startsWith('rgba:')) {
        return '#' + color.substring(5)
    }
    // named color
    return color;
}
