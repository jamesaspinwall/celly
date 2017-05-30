var SocketKlass = "MozWebSocket" in window ? MozWebSocket : WebSocket;
var ws = new SocketKlass('ws://' + window.location.host + '/ws');
ws.onmessage = function (msg) {
  data = JSON.parse(msg.data)
  if (data[0].constructor == Array) {
    for (var i = 0; i < data.length; ++i) {
      apply_me(data[i])
    }
  }
  else {
    apply_me(data)
  }
};

ws.onopen = function(){
  server('ready')
}

function apply_me(data) {
  var fun = data.shift()
  console.log('fun: '+fun)
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
  write_html: function(html){
    document.write(html);
  },
  write_layout: function(data){
    $('body').append(data)
  }
}



