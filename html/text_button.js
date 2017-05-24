text_template = `<div class="form-group">
        <label for="{{id}}">{{id}}:</label>
      <input id='{{id}}' type="text" class="form-control">
        </div>`

text_template_function = Handlebars.compile(text_template)
$('body').append(text_template_function({id: 'name'}))

$("input:text").change(function () {
  console.log(this.id + ': ' + this.value)
})
