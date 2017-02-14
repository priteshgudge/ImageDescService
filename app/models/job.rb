class Job < ActiveRecord::Base
  def json_enter_params
    enter_params ? ActiveSupport::JSON.decode(enter_params) : {}
  end
  def json_exit_params
    exit_params ? ActiveSupport::JSON.decode(exit_params) : {}
  end
end
