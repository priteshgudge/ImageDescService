class DeviseCreateAdminUsers < ActiveRecord::Migration
  def self.up
    create_table(:admin_users) do |t|
      # t.database_authenticatable :null => false
      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      # t.recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      #t.rememberable
      t.datetime :remember_created_at

      #t.trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.string :login
      t.timestamps
    end

# NOTE ESH: we since have backed away from using admin_users, this migration gets backed out later
    # Create a default user
#    AdminUser.create!(:email => 'admin@example.com', :login => 'admin@example.com', :password => 'password', :password_confirmation => 'password', :authentication_token => 'testing')

    add_index :admin_users, :email,                :unique => true
    add_index :admin_users, :reset_password_token, :unique => true
    # add_index :admin_users, :confirmation_token,   :unique => true
    # add_index :admin_users, :unlock_token,         :unique => true
 #   add_index :admin_users, :authentication_token, :unique => true
  end

  def self.down
    drop_table :admin_users
  end
end
