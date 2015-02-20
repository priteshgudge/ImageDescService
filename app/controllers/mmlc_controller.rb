require "net/http"
class MmlcController < ApplicationController
  def equation
    #call MathML Cloud 
    http = Net::HTTP.new(MATHML_CLOUD_BASE_PATH, 443)
    http.use_ssl = true
    postURI = "/equation?subscription-key=" + MATHML_CLOUD_SUBSCRIPTION_KEY
    request = Net::HTTP::Post.new("/equation?subscription-key=" + MATHML_CLOUD_SUBSCRIPTION_KEY)
    request.set_form_data({"math" => params[:math], "mathType" => "AsciiMath", "description" => "true"})
    response = http.request(request)
    case response
    when Net::HTTPSuccess then
        render :json => JSON.parse(response.body)
    else
        render :json => JSON.parse(response.value)
    end
  end
end