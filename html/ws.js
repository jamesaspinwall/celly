var SocketKlass = "MozWebSocket" in window ? MozWebSocket : WebSocket;
var ws = new SocketKlass('ws://' + window.location.host + '/ws');
ws.onmessage = function (msg) {
    data = JSON.parse(msg.data)
    console.log(data)
    mark(data)
    fire()
};

