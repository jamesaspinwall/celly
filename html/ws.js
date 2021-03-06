var SocketKlass = "MozWebSocket" in window ? MozWebSocket : WebSocket;
var ws = new SocketKlass('ws://' + window.location.host + '/ws');
ws.onmessage = function (msg) {
    data = JSON.parse(msg.data)
    if (data[0].constructor == Array) {
        for (var i = 0; i < data.length; ++i) {
            ws.apply(data[i])
        }
    }
    else {
        ws.apply(data)
    }
}

ws.onopen = function () {
    console.log('Connecting')
    server('ready')
}

ws.apply = function (data) {
    var fun = data.shift()
    console.log('fun: ' + fun)
    if (fun == 'js') {
        eval(data[0])
    }
    else {
        app[fun].apply(app, data)
    }
}

function server() {
    var data = []
    for (var i = 0; i < arguments.length; i++) {
        data.push(arguments[i])
    }
    ws.send(JSON.stringify(data))
}

app = {
    log: function (msg) {
        console.log(msg)
    },
    write_html: function (html) {
        document.write(html);
    },
    write_layout: function (data) {
        $('body').append(data)
    },
    ready: function (data) {
        console.log('Connected')

    }
}


if (false) {
    SocketKlass = "MozWebSocket" in window ? MozWebSocket : WebSocket;
    ws = new SocketKlass('ws://' + window.location.host + '/ws');
    ws.onmessage = function (msg) {
        console.log(msg.data)
    }
    ws.onopen = function () {
        console.log('onopen')
    }
}



