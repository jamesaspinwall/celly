# ---------- NEO -----------
require 'neo4j'
require 'neo4j/core/cypher_session/adaptors/http'
if ENV['user'].nil? or ENV['password'].nil?
  puts 'Missing ENV user and password'
  exit
end
Neo4j::ActiveBase.on_establish_session {Neo4j::Core::CypherSession.new(
  Neo4j::Core::CypherSession::Adaptors::HTTP.new("http://#{ENV['user']}:#{ENV['password']}@localhost:7474")
)}

Dir['../asset_portal/app/models/*.rb'].each do |file|
  load file
end


if false
  Neo4j::Session.open(:server_db, 'http://localhost:7474', basic_auth: {username: ENV['user'], password: ENV['password']})
  Neo4j::Node.create(name: 'a')
end

class UsersController

  def ready
    head = IO.read('html/user/head.html')
    ['write_html', head]
  end

  def render_layout
    layout = IO.read('html/user/layout.html')
    ['write_layout', layout]
  end

  def load_text_template(name)
    template = IO.read("html/#{name}")
    ['load_text_template', template]
  end

  def load_row_template(name)
    template = IO.read("html/#{name}")
    ['load_row_template', template]
  end

  def load_js(name)
    code = IO.read("html/#{name}")
    ['js', code]
  end

  def index
    [['clear_rows']] +
      User.all.order(:name).map do |user|
        data = user.attributes.merge(id: user.id)
        ['add_row', data]
      end
  end

  def add
    @user = User.new
    ['edit', @user.attributes]
  end

  def read(id)
    @user = User.find(id)
    data = @user.attributes.merge(id: @user.id)
    ['edit', data]
  end

  def input(data)
    data.each_pair do |field, value|
      @user[field] = value
    end
    nil
  end

  def save
    is_new = @user.id.nil?
    if @user.save
      data = @user.attributes.merge(id: @user.id)
    end
    [is_new ? ['add_row', data] : ['update_row', data], ['js', "$('#user').modal('toggle')"]]
  end

  def cancel
    @user = nil
  end

  def delete(id)
    user = User.find(id)
    user.destroy
    ['remove_row', id]
  end

  def logout
    ['js','console.log("I am out of here")']
  end
end

class PeopleController
  def index
    [['clear_rows']]
  end
end