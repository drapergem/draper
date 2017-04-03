require 'spec_helper'
require 'dummy/config/environment'
require 'ammeter/init'
require 'generators/rails/install_generator'

describe Rails::Generators::InstallGenerator do
  destination File.expand_path('../tmp', __FILE__)

  before { prepare_destination }
  after(:all) { FileUtils.rm_rf destination_root }

  describe 'the application decorator' do
    subject { file('app/decorators/application_decorator.rb') }

    describe 'naming' do
      before { run_generator %w(YourModels) }

      it { is_expected.to contain 'class ApplicationDecorator' }
    end
  end
end
