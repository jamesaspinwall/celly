var SocketKlass = "MozWebSocket" in window ? MozWebSocket : WebSocket;
var ws = new SocketKlass('ws://' + window.location.host + '/timeinfo');
ws.onmessage = function(msg){
  document.getElementById('current-time').innerHTML = msg.data;
}
