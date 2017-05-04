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

function a(n) {
  console.log('A')
  console.log(n)
}

function b(x) {
  console.log('B')
  console.log(x['b'])
}

function c(p) {
  console.log('C')
}

function de(p) {
  console.log('DE')
  console.log(p.d)
  console.log(p.e)
}
base = 0
marks = []
associates = []
funs = {}

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
  var pos = marks.indexOf(symbol)
  if (pos == -1) {
    pos = marks.length
    marks.push(symbol)
  }
  return (1 << pos)
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
  var i = 0
  while (i < associates.length) {
    associate = associates[i]
    if ((associate[0] & base) == associate[0]) {
      associate[1](funs)
      base &= ~associate[0]
      i = 0
    }
    else {
      ++i
    }
  }
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


function mark(sa) {
//    if (sa.constructor === String)
  mark_one(sa[0], sa[1])
//    else if (sa.constructor === Array)
//        mark_many(sa)
//    else
//        throw 'Error: argument should be a string or an array'
}
function mark_one(s, f) {
  base |= (1 << marks.indexOf(s))
  funs[s] = f
}

function mark_many(a) {
  for (var i = 0; i < a.length; ++i) {
    mark_one(a[i])
  }
}
function unmark(s) {
  base &= (~(1 << marks.indexOf(s)))
}
function is_marked(s) {
  var ret
  var is = base & (1 << marks.indexOf(s))
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

function turn_on(arr) {
  var byte = 0
  for (var i = 0; i <= marks.length; ++i) {
    byte(1 << marks.indexOf(s))
  }
}

function test_marks() {
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

//test_associates()
associate('a', a)
associate('b', b)
associate('c', c)
associate(['d', 'e'], de)

console.log('Done')

