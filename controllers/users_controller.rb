# ---------- NEO -----------
require 'neo4j'
require 'neo4j/core/cypher_session/adaptors/http'

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

  def index
    [['clear_rows']] +
      User.all.order(:name).map do |user|
        data = user.attributes.merge(id: user.id)
        ['add_row', data]
      end
  end

  def create
    @user = User.new
    ['edit', @user.attributes]
  end

  def read(id)
    @user = User.find(id)
    data = @user.attributes.merge(id: @user.id)
    ['edit', data]
  end

  def update(data)
    is_new = @user.id.nil?
    if @user.update(data)
      data = @user.attributes.merge(id: @user.id)
      is_new ? [['add_row', data],['js',"$('#user').modal('toggle')"]] : ['update_row', data]
    end
  end

  def cancel
    @user = nil
  end

  def delete(id)
    user = User.find(id)
    user.destroy
    ['remove_row', id]
  end

  def save

  end
end

class PeopleController
  def index
    [['clear_rows']]
  end
end