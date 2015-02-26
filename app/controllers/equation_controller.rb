class EquationController < ApplicationController
  def create
    @equation = Equation.create({:element => params[:element], :source => params[:source], :dynamic_image_id => params[:dynamic_image_id], :described_at => params[:described_at], :submitter_id => current_user.id}) if params[:element]
    render :json => @equation, :callback => params[:callback]
  end

  def get
    @equation = Equation.find(params[:id])
    render :json => @equation
  end
end
