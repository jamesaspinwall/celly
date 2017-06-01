app.template = {}

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
  $('#' + data.id + ' > td:nth-child(2)').text(data.email)
}

app.edit = function (data) {
  $('#user').modal('toggle')
  _.each(_.keys(_.omit(data,'id')), function (field) {
    $('#' + field).val(data[field])
  })
}

app.render_fields = function (parent, fields) {
  _.each(fields, function (n) {
    $(parent).append(app.template.text({id: n.name, label: n.label}))
  })
}

app.load_row_template = function (template) {
  app.template.row = Handlebars.compile(template)
}

app.load_text_template = function (template) {
  app.template.text = Handlebars.compile(template)
  $('#search').append(app.template.text({id: 'search', label: 'Search'}))

  // render all input fields
  app.render_fields('.modal-body', [{name: 'name', label: 'Name'}, {name: 'email', label: 'Email'}])

  // when change, all input fields will send [id,value]
  $('.form-group input').change(function () {
    var field = {}
    field[this.id] = this.value
    server('input', field)
  })
}

// action buttons
$('.action').click(function () {
  server(this.id)
})


server('load_row_template', 'user/row_template.html')
server('load_text_template', 'user/text_template.html')
server('index')
