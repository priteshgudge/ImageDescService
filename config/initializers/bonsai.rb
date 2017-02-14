# Following the example in: https://gist.github.com/2041121

if ENV['BONSAI_URL']
  ENV['ELASTICSEARCH_URL'] = ENV['BONSAI_URL']
  Tire.configure do
    url ENV['BONSAI_URL']
  end
  BONSAI_INDEX_NAME = ENV['BONSAI_URL'][/[^\/]+$/]
else
  app_name = Rails.application.class.parent_name.underscore.dasherize
  app_env = Rails.env
  BONSAI_INDEX_NAME = "#{app_name}-#{app_env}"
end

