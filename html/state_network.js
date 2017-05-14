base = 0
labels = []
associates = []
args = []
flow = {}
setings = []

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

    fire()
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

