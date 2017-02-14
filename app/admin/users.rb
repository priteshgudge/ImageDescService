ActiveAdmin.register User do  
  menu :if => proc{ can? :admin_user, @all }
  # returns non-deleted users all libraries 
  scope_to :current_library, :association_method => :related_users
  
  form do |f|
      f.inputs "User Details" do
      f.input :username
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :subject_expertises, :label => 'Subject Matter Expertises', :as => :select, :collection =>  SubjectExpertise.all.map {|subject| [subject.name, subject.id]}, :include_blank => nil
      f.input :other_subject_expertise, :label => 'Other Expertise'
      f.input :password
      f.input :password_confirmation    
      f.input :use_new_library, :label => 'Click to Create a new library', :as => :boolean, :input_html => {:class => 'book-toggle', 'data-related-off' => '.library-select', 'data-related-on' => '.new-library'}  
      f.input :libraries, :as => :select, :collection => Library.all.map {|library| [library.name, library.id]}, :include_blank => nil, :multiple => true
      f.input :new_library, :label => 'New Library', :wrapper_html => {:class => 'new-library'}
      
      if !f.object.new_record? 
          f.input :use_delete_library, :label => 'Click to Delete a existing library', :as => :boolean, :input_html => {:class => 'book-toggle', 'data-related-off' => '.library-select', 'data-related-on' => '.delete-library'}  
          f.input :delete_library, :label => 'Delete Library', :wrapper_html => {:class => 'delete-library'}
      end
      # dropdown of roles
      f.input :roles, :as => :select, :collection => Role.all.map {|role| [role.name, role.id]}, :include_blank => nil
    end
    f.buttons
  end
  

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
   # default_actions  
    column :actions do |user|
      links = link_to I18n.t('active_admin.view'), resource_path(user)
      links += " "
      links += link_to I18n.t('active_admin.edit'), edit_resource_path(user)
      links += " "
      links += link_to "Delete", admin_user_delete_path(:user_id => user.id), :confirm=>'Are you sure?'
      links
    end
  end
  
  filter :libraries, :as => :select
  filter :roles, :as => :select
  filter :username
  filter :email
  filter :subject_expertises, :as => :select
  filter :other_subject_expertise
  
  show do
      attributes_table :id do 
                        row ("First Name") { user.first_name }
                        row ("Last Name") { user.last_name }
                        row ("Username") { user.username }
                        row ("Subject Matter Expertise") {  User.connection.select_value "select group_concat(subject_expertises.name separator ', ') from user_subject_expertises, subject_expertises where 
                               user_subject_expertises.user_id = #{user.id} and user_subject_expertises.subject_expertise_id = subject_expertises.id"}
                        row ("Other Expertise") { user.other_subject_expertise }
                        row ("Email") { user.email }
                        row ("Library") { User.connection.select_value "select group_concat(libraries.name separator ', ') from user_libraries, libraries where 
                                 user_libraries.user_id = #{user.id} and user_libraries.library_id = libraries.id"}
                        row ("Role") { User.connection.select_value "select group_concat(roles.name separator ', ') from user_roles, roles where 
                               user_roles.user_id = #{user.id} and user_roles.role_id = roles.id"}    
      end
  end
  
end

