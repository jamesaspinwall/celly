app = {
  disable_a: function () {
    $('#a').addClass("disabled")
  },
  disable_b: function () {
    $('#b').addClass("disabled")
  },
  enable_a: function () {
    $('#a').removeClass("disabled")
  },
  enable_b: function () {
    $('#b').removeClass("disabled")
  },
  run: function (what) {
    for (var i = 0; i < what.length; i++) {
      what[i]()
    }
  }
}
x = [app.disable_a, app.disable_b]
y = [app.enable_a, app.enable_b]

base = 0
labels = []
associates = []
args = []
flow = {}
setings = []

function check_one(variable, v_type) {
  if (variable.constructor !== v_type)
    throw "Error, expected correct type"
}

function check_many(arr) {
  for (var i = 0; i < arr.length; ++i) {
    check_one(arr[i][0], arr[i][1])
  }
}

function to_bin(symbol) {
  var pos = labels.indexOf(symbol)
  if (pos == -1) {
    pos = labels.length
    labels.push(symbol)
  }
  return (1 << pos)
}

function mark(sa, params) {
  if (sa.constructor === Array)
    mark_one(sa[0], sa[1])
  else if (sa.constructor === String)
    mark_one(sa, params)
  else
    throw 'Error: argument should be a string or an array'
}
function mark_one(s, arg) {
  var bits = (1 << labels.indexOf(s))
  base |= bits
  args[bits] = arg
}

function set(node, value) {
  setings.push([node, value])
}

function mark_many(a) {
  for (var i = 0; i < a.length; ++i) {
    mark_one(a[i])
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
  //check_many([[symbols, Array], [method, Function]])
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
        working_base &= ~associate[0] // turn-off input bits
        var index = 1
        var params = []
        for (var k = 0; k < labels.length; ++k) {
          if ((index & associate[0]) > 0)
            params.push(args[index])
          index <<= 1
        }
        ret = associate[1].apply(flow, params)
        if (ret !== undefined)
          if (ret[0].constructor == Array) {
            for (var j = 0; j < ret.length; ++j)
              returns.push(ret[j])
          } else if (ret[0].constructor == String) {
            returns.push([ret[0], ret[1]])
          }

        changed = true
      }
    }

    base = working_base
    for (var i = 0; i < returns.length; ++i) {
      if (returns[i].constructor == Array)
        mark(returns[i])
    }
    for (var i = 0; i < setings.length; ++i) {
      mark(setings[i])
    }

  }
  return -1
}

function test_associates() {
  associate('a', a)
  associate('b', b)
  associate('c', c)
  associate(['d', 'e'], de)
  mark('a')
  fire()
  assert(base, 0)
  mark('b')
  fire()
  assert(base, 0)
  mark('c')
  fire()
  assert(base, 0)
  mark('a')
  mark('c')
  fire()
  mark('d')
  fire()
  assert(base, 8)
  mark('e')
  assert(base, 24)
  fire()
  assert(base, 0)

  mark(['e', 'd'])
  assert(base, 24)
  fire()
  assert(base, 0)

}


function test_labels() {
  mark('b')
  assert(2, base)
  mark('c')
  assert(6, base)
  unmark('b')
  assert(4, base)
  assert(is_marked('c'), true)
  assert(is_marked('b'), false)

}

function assert(a, b) {
  if (a != b) {
    console.log('Error: ' + a + ' != ' + b)
  }
}

function a(n) {
  console.log('a(n): ' + n)
  return ([['b', {b: 888}], ['e', 55]])
}
function aa(p) {
  console.log('aa(p):' + p)
}

function b(x) {
  console.log('B')
  console.log(x['b'])
  return (['c', 'James'])
}

function c(name) {
  console.log('C')
  console.log(name)
  return (['d', 111])
}

function de(d, e) {
  console.log('DE')
  console.log(d)
  console.log(e)
}

function def(d, e, f) {
  console.log('def(d,e,f): ' + d + ',' + e + ',' + f)
}

function join(a, b, c) {
  console.log('join(a,b,c): ' + a + ',' + b + ',' + c)
}
function dd(d) {
  console.log('dd: ' + d)
}

function no(n, o) {
  console.log('no(n,o): ', n + ',' + o)
}

function m(n) {
  console.log(n)
  return (['ab1', 3 * n])
}
function n(p) {
  c = p * 2
  console.log(c)
  return ([['xy1', c]])
}

function o(a, b) {
  console.log(a + b)
}


//test_associates()
associate('a', a)
associate('b', b)
associate('c', c)
associate(['d', 'e'], de)
associate('d', dd)
associate(['x', 'y', 'z'], join)
associate('a', aa)
associate(['d', 'e', 'f'], def)
associate(['n', 'o'], no)
set('n', 999)
mark('a', 777)
mark('z', 3)
mark('x', 1)
mark('y', 2)
mark('f', '000')
mark('o',0)
associate('ab', m)
associate('xy', n)
associate(['ab1', 'xy1'], o)

fire()

mark('o', 100000)
fire()




mark('ab', 10)
mark('xy', 20)

fire()

console.log('Done')