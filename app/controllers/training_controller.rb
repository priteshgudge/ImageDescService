class TrainingController < ApplicationController
  def index
  end

  def decision_tree
    @questionnaire = JSON.parse(File.read("#{Rails.root}/public/ImageSortingTool.json"))
  end

  def tools_and_exapmles
  end
end
