class AltController < ApplicationController
  def create
    @alt = Alt.create({:alt => params[:alt], :dynamic_image_id => params[:dynamic_image_id], :submitter_id => current_user.id, :from_source => params[:from_source]}) if params[:alt]
    render :json => @alt, :callback => params[:callback]
  end

  def get
    @alt = Alt.find(params[:id])
    render :json => @alt
  end

  def get_current
    @alt = Alt.where(:dynamic_image_id => params[:dynamic_image_id]).last();
    render :json => @alt 
  end

end
