require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/draper/install/install_generator'

describe Draper::InstallGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  context 'using rspec' do
    before { run_generator }

    shared_examples_for "ApplicationDecoratorGenerator" do
      describe 'app/decorators/application_decorator.rb' do
        subject { file('app/decorators/application_decorator.rb') }
        it { should exist }
        it { should contain "class ApplicationDecorator < Draper::Base" }
      end
    end
    
    describe 'spec/decorators/application_decorator_spec.rb' do
      subject { file('spec/decorators/application_decorator_spec.rb') }
      it { should exist }
      it { should contain "describe ApplicationDecorator do" }
    end
  end
  
  context "using test_unit" do
    before { run_generator ["", "-t=test_unit"]  }
    
    it_should_behave_like "ApplicationDecoratorGenerator"
    
    describe 'spec/decorators/application_decorator_spec.rb' do
      subject { file('spec/decorators/application_decorator_spec.rb') }
      it { should_not exist }
    end
    
    describe 'spec/decorators/application_decorator_test.rb' do
      subject { file('test/decorators/application_decorator_test.rb') }
      it { should exist }
    end
  end

end
