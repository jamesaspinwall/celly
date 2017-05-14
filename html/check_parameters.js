function check_one(variable, v_type) {
    if (variable.constructor !== v_type)
        throw "Error, expected correct type"
}

function check_many(arr) {
    for (var i = 0; i < arr.length; ++i) {
        check_one(arr[i][0], arr[i][1])
    }
}

