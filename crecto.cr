require "pg"
require "crecto"

Crecto::DbLogger.set_handler(STDOUT)

module DB
  extend Crecto::Repo

  config do |conf|
    conf.adapter = Crecto::Adapters::Postgres
    conf.uri = "postgres://root@localhost/roadie"
  end
end

class User < Crecto::Model
  schema "users" do
    field :email, String
    field :password, String
  end

  has_many :permissions, Permission
  validate_required [:email, :password]
end

class Project < Crecto::Model
  schema "projects" do
    field :title, String
  end
  has_many :permissions, Permission
  validate_required [:title]
end

class Permission < Crecto::Model
  schema "permissions" do
    field :user_id, Int64
    field :project_id, Int64
  end
  belongs_to :user, User
  belongs_to :project, Project
end

# Create user
user = User.new
user.email = "shf@shf.com"
user.password = "12345"
puts DB.insert(user).errors

# Create project
project = Project.new
project.title = "My Project"
puts DB.insert(project).errors

# Create permision
user = DB.get_by(User, email: "shf@shf.com")
project = DB.get_by(Project, title: "My Project")
permission = Permission.new
permission.project = project
permission.user = user
puts DB.insert(permission).errors

# List projects and users
DB.all(Permission, Crecto::Repo::Query.preload(:user).preload(:project)).each do |permission|
  # Can't get subqueries here
  puts [permission.id, permission.user, permission.project]
end

# Delete everything
Crecto::Multi.new.delete_all(Permission)
Crecto::Multi.new.delete_all(Project)
Crecto::Multi.new.delete_all(User)
