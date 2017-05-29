var SocketKlass = "MozWebSocket" in window ? MozWebSocket : WebSocket;
var ws = new SocketKlass('ws://' + window.location.host + '/ws');
ws.onmessage = function (msg) {
  console.log(msg)
  data = JSON.parse(msg.data)
  if (data[0].constructor == Array){
    for(var i=0; i<data.length; ++i){
      apply_me(data[i])
    }
  }
  else {
    apply_me(data)
  }
};

ws.send_obj = function (obj) {
  ws.send(JSON.stringify(obj))
}

function server(){
  var data=[]
  for (var i = 0; i < arguments.length; i++) {
    data.push(arguments[i])
  }
  ws.send_obj(data)
}

function apply_me(data){
  var fun = data.shift()
  if (fun == 'js'){
    eval(data[0])
  }
  else {
    app[fun].apply(app, data)
  }
  //mark(data)
  //fire()
}

app={
  name: function(name){
    $('#name').val(name)
  },
  log: function(a,b){
    console.log(a)
    console.log(b)
    console.log(this.a)
  },
  a: 'I am here'
}

