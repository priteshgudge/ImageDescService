class TrainingController < ApplicationController
  def index
  end

  def decision_tree
  end

  def questionnaire
  	render :json => JSON.parse(File.read("#{Rails.root}/public/ImageSortingTool.json"))['questionnaire']['questions']
  end

  def tools_and_exapmles
  end

  def how_to
  end
end
