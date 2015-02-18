class DeleteUserRoleScreener < ActiveRecord::Migration
  def up
    execute "delete from user_roles where role_id = 4"
    execute "delete from roles where id = 4"
  end

  def down
  end
end
