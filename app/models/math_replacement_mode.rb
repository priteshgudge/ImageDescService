class MathReplacementMode < ActiveRecord::Base
  def as_json(options = {})
    json = super(options)
    json['id'] = self.id
    json['mode'] = self.mode
    json
  end
end
