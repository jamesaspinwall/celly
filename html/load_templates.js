// APP

app.clear_rows = function () {
  $('#contacts tr').remove()
}

app.add_row = function (data) {
  $('#contacts').append(app.template.row(data))
  // Event attached to the newly created delete button
  $('#delete-' + data.id).click(function (e) {
    var id = e.target.id.substr(7)
    server('delete', id)
  })

  $('#edit-' + data.id).click(function (e) {
    var id = e.target.id.substr(5)
    server('read', id)
  })
}

app.remove_row = function (id) {
  $('#' + id).remove()
}

app.update_row = function (data) {
  $('#' + data.id + ' > td:nth-child(1)').text(data.name)
}

app.edit = function (data) {
  $('#user').modal('toggle')
  $('#name').val(data.name)
}

// TEMPLATES
app.template = {}
app.load_row_template = function (template) {
  app.template.row = Handlebars.compile(template)
}

app.load_text_template = function (template) {
  app.template.text = Handlebars.compile(template)
  $('#input').append(app.template.text({id: 'search', label: 'Search'}))
}

$('#add').click(function (e) {
  server('create')
})

$('#close').click(function(){
  server('cancel')
})
$('#name').change(function () {
  server('update', {name: this.value})
})

$('#save').click(function (e) {
  server('save')
})


server('load_row_template', 'user/row_template.html')
server('load_text_template', 'user/text_template.html')
server('index')
