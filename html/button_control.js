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
      set('template', Handlebars.compile(template))
      //mark('template',Handlebars.compile(template))
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
  }
}

function load_ankura() {
  associate('load_template', row.load_template)
  associate('load_data', row.load_data)
  associate(['template', 'data'], row.render)
  mark('load_template', '_handlebar.html')
  mark('load_data', 'data.json')
  fire()
}


associate('compile', row.compile)
associate(['template', 'data'], row.render)

template='<div><pre>{{title}}</pre><div>{{body}}</div></div>'
mark('compile',template,true)
