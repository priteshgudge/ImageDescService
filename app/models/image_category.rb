class ImageCategory < ActiveRecord::Base
  def as_json(options = {})
    json = super(options)
    json['id'] = self.id
    json['name'] = self.id
    json
  end
end
