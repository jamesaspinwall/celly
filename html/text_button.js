// TEMPLATES


$.get('/user/text_template.html', function (template) {
  text_template = Handlebars.compile(template)
  $('#input').append(text_template({id: 'search', label: 'Search'}))
})

$.get('/user/row_template.html', function (template) {
  row_template = Handlebars.compile(template)
})

$(function () {

  $('#add').click(function (e) {
    server('create')
  })

  $('#name').change(function () {
    server('update', {name: this.value})
  })

  // APP
  app.clear_rows = function () {
    $('#contacts tr').remove()
  }

  app.add_row = function (data) {
    $('#contacts').append(row_template(data))
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
    $('#user').modal('toggle')
  }

  app.edit = function (data) {
    $('#user').modal('toggle')
    $('#name').val(data.name)
  }

  if (!text_template.undefined && !row_template.undefined) {
    server('index')
  }
})