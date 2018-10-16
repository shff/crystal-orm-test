require "jennifer"
require "jennifer/adapter/postgres"

Jennifer::Config.configure do |config|
  config.from_uri("postgres://root@localhost/roadie")
end

class User < Jennifer::Model::Base
  mapping(
    id: Primary64,
    email: String,
    password: String,
    updated_at: {type: Time, null: true},
    created_at: {type: Time, null: true},
  )
  with_timestamps
  has_many :permissions, Permission
end

class Project < Jennifer::Model::Base
  mapping(
    id: Primary64,
    title: String,
    updated_at: {type: Time, null: true},
    created_at: {type: Time, null: true},
  )
  with_timestamps
  has_many :permissions, Permission
end

class Permission < Jennifer::Model::Base
  mapping(
    id: Primary64,
    user_id: Int64,
    project_id: Int64,
    updated_at: {type: Time, null: true},
    created_at: {type: Time, null: true},
  )
  with_timestamps

  belongs_to :user, User
  belongs_to :project, Project
end

Jennifer::Adapter.adapter.transaction do
  # Create user and project
  user = User.create(email: "shf@x.com", password: "asdfg")
  project = Project.create(title: "Project X")
  permission = Permission.create(user_id: user.id, project_id: project.id)

  # List projects and users
  Permission.all.eager_load(:user).eager_load(:project).each do |permission|
    p [permission.user!.email, permission.project!.title]
  end

  # Delete everything
  permission.destroy
  project.destroy
  user.destroy
end
