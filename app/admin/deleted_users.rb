ActiveAdmin.register User, :as => "DeletedUsers" do    
  menu :if => proc{ can? :admin_user, @all }
  # returns deleted users all libraries 
  scope_to :current_library, :association_method => :related_deleted_users


  index do
    column :id
    column :first_name
    column :last_name
    column :username
    column  "Subject Matter Expertise" do |user| 
      User.connection.select_value "select group_concat(subject_expertises.name separator ', ') from user_subject_expertises, subject_expertises where 
           user_subject_expertises.user_id = #{user.id} and user_subject_expertises.subject_expertise_id = subject_expertises.id"     
    end
    column "Other Expertise", :other_subject_expertise
    column :email
    column "Library" do |user|
      User.connection.select_value "select group_concat(libraries.name separator ' ') from user_libraries, libraries where 
           user_libraries.user_id = #{user.id} and user_libraries.library_id = libraries.id"
      end
    column "Role" do |user|
      User.connection.select_value "select group_concat(roles.name separator ' ') from user_roles, roles where 
           user_roles.user_id = #{user.id} and user_roles.role_id = roles.id"
    end
    column :deleted_at
  end
  
  filter :user_libraries_library_id, :as => :select, :collection => proc { Library.all}, :label => 'Library'
  filter :user_roles_role_id, :as => :select, :collection => proc { Role.all}, :label => 'Role'
  filter :username
  filter :email
  filter :user_subject_expertises_subject_expertise_id, :as => :select, :collection => proc { SubjectExpertise.all}, :label => 'Subject Matter Expertise'
  filter :other_subject_expertise
  
end