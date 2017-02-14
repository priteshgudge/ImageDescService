require "net/http"
class MmlcController < ApplicationController
  def equation
    #call MathML Cloud 
    http = Net::HTTP.new(MATHML_CLOUD_BASE_PATH, 443)
    http.use_ssl = true
    request = Net::HTTP::Post.new("/equation?subscription-key=" + MATHML_CLOUD_SUBSCRIPTION_KEY)
    request.set_form_data({"math" => params[:math], "mathType" => params[:math_type], "description" => "true", "mml" => "true"})
    response = http.request(request)
    case response
    when Net::HTTPSuccess then
        render :json => JSON.parse(response.body)
    else
        logger.warn "MathML Cloud Error " + response.code + ": " + response.value
        render :json => JSON.parse(response.value)
    end
  end
end