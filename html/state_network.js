base = 0
labels = []
associates = []
args = []
flow = {}
settings = 0

function to_bin(symbol) {
  var pos = labels.indexOf(symbol)
  if (pos == -1) {
    pos = labels.length
    pos = labels.length
    labels.push(symbol)
  }
  return (1 << pos)
}

// function set(label, value) {
//   if (value == undefined)
//     throw 'Error, label, value required'
//
//   var pos = labels.indexOf(label)
//   if (pos == -1)
//     throw 'Error label (' + label + ') is not associated'
//
//   settings |= 2 ** pos
//   mark(label, value)
// }

function mark(sa, params,set) {
  if (sa.constructor === Array)
    mark_one(sa[0], sa[1])
  else if (sa.constructor === String)
    mark_one(sa, params,set)
  else
    throw 'Error: argument should be a string or an array'
  //fire()
}

function mark_one(label, value,set) {
  if (value == undefined)
    throw 'Error, label, value required'

  pos = labels.indexOf(label)
  if (pos == -1)
    throw 'Error label (' + label + ') is not associated'

  var bits = (1 << pos)
  base |= bits
  args[bits] = value
  if (set == true)
    settings |= 2 ** pos

}

function mark_many(marks) {
  for (var i = 0; i < marks.length; ++i) {
    mark_one(marks[i])
  }
}

function unmark(s) {
  base &= (~(1 << labels.indexOf(s)))
}
function is_marked(s) {
  var ret
  var is = base & (1 << labels.indexOf(s))
  if (is == 0) {
    ret = false
  }
  else {
    ret = true
  }
  return ret
}

function unset(binary) {
  base & ~binary
}

function turn_on() {
  var byte = 0
  for (var i = 0; i <= labels.length; ++i) {
    byte(1 << labels.indexOf(s))
  }
}

function associate(symbols, method) {
  var binary = 0

  if (symbols.constructor === Array) {
    for (var i = 0; i < symbols.length; ++i) {
      binary |= to_bin(symbols[i])
    }
  } else if (symbols.constructor === String) {
    binary |= to_bin(symbols)
  }
  associates.push([binary, method])
}

function fire() {
  var changed = true
  while (changed) {
    var working_base = base
    var returns = []

    changed = false
    for (var i = 0; i < associates.length; ++i) {
      var associate = associates[i]
      if ((associate[0] & base) == associate[0]) {
        working_base &= (~associate[0]) // turn-off input bits
        var index = 1
        var params = []
        for (var k = 0; k < labels.length; ++k) {
          if ((index & associate[0]) > 0)
            params.push(args[index])
          index <<= 1
        }
        ret = associate[1].apply(flow, params)
        if (ret !== undefined) {
          if (ret[0].constructor == Array)
            for (var j = 0; j < ret.length; ++j)
              returns.push(ret[j])
          else if (ret[0].constructor == String)
            returns.push([ret[0], ret[1]])
          changed = true
        }
      }
    }

    base = working_base
    for (var i = 0; i < returns.length; ++i) {
      if (returns[i].constructor == Array)
        mark(returns[i])
    }
  }
  base |= settings
  return 'ok'
}

