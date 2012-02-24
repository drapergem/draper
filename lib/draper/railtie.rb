require 'rails/railtie'

module Draper
  class Railtie < Rails::Railtie

    initializer "draper.extend_action_controller_base" do |app|
      ActiveSupport.on_load(:action_controller) do
        Draper::System.setup(:action_controller)
      end
    end

    initializer "draper.extend_action_mailer_base" do |app|
      ActiveSupport.on_load(:action_mailer) do
        Draper::System.setup(:action_mailer)
      end
    end

  end
end
