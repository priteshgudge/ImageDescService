class ApplicationController < ActionController::Base
  # needed to commment out the following to allow cached, transformed html to make authenticated post requests
  #protect_from_forgery
  require 'active_admin_views_pages_base.rb'
  helper_method :current_library
  
  def load_book
    if !params[:book_id].blank?
      Book.where(:id => params[:book_id], :library_id => current_library.id, :deleted_at => nil).first rescue nil
    elsif !(params[:book_uid] || params[:book_id]).blank?
      Book.where(:uid => (params[:book_uid] || params[:book_id]), :library_id => current_library.id, :deleted_at => nil).first
    end
  end
  
  def authenticate_admin_user!
    authenticate_user!
    redirect_to '/' unless current_admin_user
  end
  
  def current_admin_user
    current_user if can? :view_admin, @all
  end
  
  def current_library
    current_user.libraries.first if current_user
  end
end
