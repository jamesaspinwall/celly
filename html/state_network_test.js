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
