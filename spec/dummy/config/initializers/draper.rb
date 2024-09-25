Rails.application.config.to_prepare do
  Draper.configure do |config|
    config.default_controller = BaseController
  end
end
