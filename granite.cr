require "granite"
require "granite/adapter/pg"

Granite::Adapters << Granite::Adapter::Pg.new({name: "pg", url: "postgres://root@localhost/roadie"})

class Users < Granite::Base
  adapter pg
  field email : String
  field password : String
  timestamps

  has_many permissions : Permissions
end

class Projects < Granite::Base
  adapter pg
  field title : String
  timestamps

  has_many permissions : Permissions
end

class Permissions < Granite::Base
  adapter pg

  belongs_to user : Users
  belongs_to project : Projects
end

Permissions.all.each { |u| u.destroy! }
Projects.all.each { |u| u.destroy! }
Users.all.each { |u| u.destroy! }

user = Users.create!(email: "shf@shf.com", password: "12345")
project = Projects.create!(title: "My Project")
permission = Permissions.create!(user_id: user.id, project_id: project.id)

Permissions.all.each do |permission|
  p [permission.project, permission.user]
end

permission.destroy!
project.destroy!
user.destroy!
