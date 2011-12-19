module Draper
  # Requiring decorators so they can be registered by models on initialization
  class Railtie < Rails::Railtie
    initializer "draper.load_dependencies" do |app|
      app.config.to_prepare do
        Dir.glob("#{Rails.root}/app/decorators/**/*.rb").each{ |file| require_dependency file}
      end
    end
  end
end