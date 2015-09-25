class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
     user ||= User.new # guest user (not logged in) 
    can :tag_images, :all if user.describer? || user.moderator? || user.admin? || user.content_owner?
    can :describe_images, :all if user.describer? || user.moderator? || user.admin? || user.content_owner?
    can :tag_all_images, :all if user.moderator? || user.admin?
    can :review_images, :all if user.moderator? || user.admin?
    can :approve_book, :all if user.admin?
    can :complete_book, :all if user.admin?
    can :reports, :all if user.admin?
    can :edit_uesrs, :all if user.admin?
    can :data_cleanup, :all if user.admin?
    can :view_admin, :all if user.admin? || user.moderator?
    can :admin_user, :all if user.admin?
    can :edit_book_content, :all if user.content_owner? || user.admin?
         
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
