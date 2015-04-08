class ImageCategory < ActiveRecord::Base
  def as_json(options = {})
    json = super(options)
    json['id'] = self.id
    json['name'] = self.name
    json
  end

  def self.MathEquations
    ImageCategory.where(:name => 'Math Equations').first
  end
end
