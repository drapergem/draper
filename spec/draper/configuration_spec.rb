require 'spec_helper'

module Draper
  RSpec.describe Configuration do
    it 'yields Draper on configure' do
      Draper.configure { |config| expect(config).to be Draper }
    end

    it 'defaults default_controller to ApplicationController' do
      expect(Draper.default_controller).to be ApplicationController
    end

    it 'allows customizing default_controller through configure' do
      default = Draper.default_controller

      Draper.configure do |config|
        config.default_controller = CustomController
      end

      expect(Draper.default_controller).to be CustomController

      Draper.default_controller = default
    end
  end
end
