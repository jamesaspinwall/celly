$(function () {
  // panel = {
  //   edit_button: function (enable) {
  //     if (enable)
  //       $('#a').removeClass("disabled")
  //     else
  //       $('#a').addClass("disabled")
  //   }
  // }
  //
  // associate('edit_button', panel.edit_button)
  // mark('edit_button', false)
  // fire()
})


window.row = {
  load_template: function (template_url) {
    $.get(template_url, function (template) {
      mark('template', Handlebars.compile(template))
      fire()
    })
  },
  load_data: function (data_url) {
    $.getJSON(data_url, function (data) {
      mark('data', data)
      fire()
    })
  },
  render: function (template, data) {
    $('#result').append(template(data))
  },
  compile: function (template) {
    return [['template', Handlebars.compile(template)]]
  },
  try_it: function (source) {
    eval(source)
  },
}

function load_ankura() {
  associate('load_template', row.load_template)
  associate('load_data', row.load_data)
  associate(['template', 'data'], row.render)
  mark('load_template', '_handlebar.html')
  mark('load_data', 'data.json')
  fire()
}

function load_js() {
  associate('try_it', row.try_it)
  associate('compile', row.compile)
  associate(['template', 'data'], row.render)

  template = '<div><pre>{{title}}</pre><div>{{body}}</div></div>'
  mark('compile', template, true)
}

window.table = {
  compile_row: function (template) {
    return [['template_function', Handlebars.compile(template)]]
  },
  render_row: function (template_function, row_values) {
    $('#contacts').append(template_function(row_values))
  }
}


associate('compile_row', window.table.compile_row)
associate(['template_function', 'row_values'], window.table.render_row)

mark('compile_row', '<tr><td>{{first}}</td><td>{{last}}</td><td>{{email}}</td></tr>', true)
//mark('row_values', {first: 'James', last: 'Aspinwall', email: 'jamesaspinwall@gmail.com'})
//fire()
