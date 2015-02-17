class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessor :login, :new_library, :use_new_library, :current_user, :from_signup, :delete_library, :use_delete_library
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, 
                   :remember_me, :username, :role_ids, :subject_expertise_ids,  :other_subject_expertise, :library_ids, :new_library, :use_new_library, :from_signup, :agreed_tos, :delete_library, :use_delete_library
  has_many :user_roles, :dependent => :destroy
  has_many :roles, :through => :user_roles
  
  has_many :user_libraries, :dependent => :destroy
  has_many :libraries, :through => :user_libraries
  validates_presence_of :libraries #,  :if => lambda{|user| !user.new_record?}
  
  has_many :user_subject_expertises, :dependent => :destroy
  has_many :subject_expertises, :through => :user_subject_expertises
  
  validates_length_of :email, :within => 6..250, :if => lambda {|user| !user.email.blank? } 
  validates_uniqueness_of :email, :if => lambda {|user| !user.email.blank? }, :scope => [:deleted_at]
  validates_presence_of  :email

  validates_length_of :username, :within => 5..40, :if => lambda {|user| !user.login.blank? } 
  validates_uniqueness_of :username, :if => lambda {|user| !user.username.blank? }, :scope => [:deleted_at] 
  validates_presence_of  :username
#  validates_uniqueness_of :username

  validates_presence_of :password, :if => lambda {|user| user.new_record? }
  validates_length_of :password, :within => 6..40, :if => lambda {|user| !user.password.blank? }
  validates_confirmation_of :password
  
  validates_presence_of  :first_name
  validates_presence_of  :last_name
  
  before_save :populate_new_library, :delete_library_if_checked
  before_create :populate_new_library, :add_user_roles
  before_validation :set_demo_library, :on => :create
  validates_acceptance_of :agreed_tos, :accept => true, :message => "To Sign up you must accept our Terms of Service", :if => lambda {|user| user.from_signup }
  validate :library_to_delete_not_linked
  
  def full_name
    [first_name, last_name].compact.join ' '
  end
 
  def has_role?(role_sym)
    roles.any? { |r| r.name.parameterize.underscore.to_sym == role_sym }
  end
  
  def admin?
    has_role? :admin
  end

  def content_owner?
    has_role? :content_owner
  end

  def moderator?
    has_role? :moderator
  end
  
  def describer?
     has_role? :describer
  end
  
  protected
  
   def self.find_for_database_authentication(warden_conditions)
     conditions = warden_conditions.dup
     login = conditions.delete(:login)
     where(conditions).where("deleted_at is null").where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
   end

   # Attempt to find a user by it's email. If a record is found, send new
   # password instructions to it. If not user is found, returns a new user
   # with an email not found error.
   def self.send_reset_password_instructions(attributes={})
     recoverable = find_recoverable_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
     recoverable.send_reset_password_instructions if recoverable.persisted?
     recoverable
   end

   def self.find_recoverable_or_initialize_with_errors(required_attributes, attributes, error=:invalid)
     (case_insensitive_keys || []).each { |k| attributes[k].try(:downcase!) }

     attributes = attributes.slice(*required_attributes)
     attributes.delete_if { |key, value| value.blank? }

     if attributes.size == required_attributes.size
       if attributes.has_key?(:login)
          login = attributes.delete(:login)
          record = find_record(login)
       else
         record = where(attributes).first
       end
     end

     unless record
       record = new
       required_attributes.each do |key|
         value = attributes[key]
         record.send("#{key}=", value)
         if login
           record.errors.add(key, value.present? ? error : "has not been previously registered")
         else
           record.errors.add(key, value.present? ? error : :blank)
         end
       end
     end
     record
   end

   def self.find_record(login)
     where(["username = :value OR email = :value", { :value => login }]).first
   end
   

   def populate_new_library
     if use_new_library.eql? "1"
        library = Library.where(:name => new_library).first
        if (!library)
          library = Library.create :name => new_library
        end   
        self.libraries = [library]   
     end
   end

   def add_user_roles
    describer = Role.where(:name => "Describer").first
    self.roles = [describer]
   end
   
  def set_demo_library
     if libraries.blank?
       library = Library.where(:name => 'Demo').first
       self.libraries = [library]
     end
  end
  
  
  def library_to_delete_not_linked
     if use_delete_library.eql? "1"
         library = Library.where(:name => delete_library).first
         if library 
           if library.user_libraries.try(:size) > 0
             errors[:use_delete_library] << "Please assign users that belong to this library to another library"
           end
           if library.books.try(:size) > 0
             errors[:use_delete_library] << "Please assign books that belong to this library to another library"
           end
         else
            errors[:use_delete_library] << "Please enter a valid library"
         end
         
    end
  end
  
  def delete_library_if_checked
    if use_delete_library.eql? "1"
       library = Library.where(:name => delete_library).first
       if library && library.user_libraries.try(:size) == 0 && library.books.try(:size) == 0
         library.destroy
       end
      
    end
  end
   
end

