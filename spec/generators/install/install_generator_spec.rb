require 'spec_helper'
require 'dummy/config/environment'
require 'ammeter/init'
require 'generators/draper/install_generator'

describe Draper::Generators::InstallGenerator do
  destination File.expand_path('../tmp', __FILE__)

  before { prepare_destination }
  after(:all) { FileUtils.rm_rf destination_root }

  describe 'the application decorator' do
    subject { file('app/decorators/application_decorator.rb') }

    before { run_generator }

    it { is_expected.to contain 'class ApplicationDecorator' }
  end
end
