module Draper
  module DecoratorExampleGroup
    extend ActiveSupport::Concern
    included { metadata[:type] = :decorator }
  end

  module DeviseHelper
    def sign_in(user)
      warden.stub :authenticate! => user
      controller.stub :current_user => user
      user
    end

    private

    def request
      @request ||= ::ActionDispatch::TestRequest.new
    end

    def controller
      return @controller if @controller
      @controller = ApplicationController.new
      @controller.request = request
      ::Draper::ViewContext.current = @controller.view_context
      @controller
    end

    # taken from Devise's helper but uses the request method instead of @request
    #   and we don't really need the rest of their helper
    def warden
      @warden ||= begin
        manager = Warden::Manager.new(nil) do |config|
          config.merge! Devise.warden_config
        end
        request.env['warden'] = Warden::Proxy.new(request.env, manager)
      end
    end
  end
end

RSpec.configure do |config|
  # Automatically tag specs in specs/decorators as type: :decorator
  config.include Draper::DecoratorExampleGroup, :type => :decorator, :example_group => {
    :file_path => /spec[\\\/]decorators/
  }

  if defined?(Devise)
    config.include Draper::DeviseHelper, :type => :decorator
  end
end

module Draper
  module RSpec
    class Railtie < Rails::Railtie
      config.after_initialize do |app|
        if defined?(Capybara)
          require 'capybara/rspec/matchers'

          ::RSpec.configure do |config|
            config.include Capybara::RSpecMatchers, :type => :decorator
          end
        end
      end
    end
  end
end

