class TrainingController < ApplicationController
  def index
  end

  def questionnaire
  	render :json => JSON.parse(File.read("#{Rails.root}/public/ImageSortingTool.json"))['questionnaire']['questions']
  end

  def decision_tree_images
    render :json => JSON.parse(File.read("#{Rails.root}/public/DecisionTreeImages.json"))['gallery']['images']
  end

  def when_to_describe
  end

  def how_to_describe
  end
end
