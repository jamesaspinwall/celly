// APP

app.clear_rows = function () {
  $('table tbody tr').remove()
}

app.add_row = function (data) {
  $('table tbody').append(app.template.row(data))
  // Event attached to the newly created delete button
  $('#delete-' + data.id).click(function () {
    server('delete', data.id)
  })

  $('#edit-' + data.id).click(function () {
    server('read', data.id)
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
  $('#search').append(app.template.text({id: 'search', label: 'Search'}))
  $('.modal-body').append(app.template.text({id: 'name', label: 'Name'}))
  $('.form-group input').change(function () {
    var field = {}
    field[this.id] = this.value
    server('input', field)
  })
}

$('.action').click(function () {
  server(this.id)
})




server('load_row_template', 'user/row_template.html')
server('load_text_template', 'user/text_template.html')
server('index')
