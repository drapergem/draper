module Draper
  # Requiring decorators so they can be registered by models on initialization
  class Railtie < Rails::Railtie
    initializer "Require decorators" do |app|
      config.after_initialize do
        Dir.glob("#{Rails.root}/app/decorators/**/*.rb").each{ |file| require_dependency file}
      end
    end
  end
end