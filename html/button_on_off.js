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

