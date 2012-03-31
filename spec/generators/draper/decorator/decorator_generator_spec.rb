require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/draper/decorator/decorator_generator'

describe Draper::DecoratorGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  context 'decorator context' do
    before { run_generator ["YourModel"]  }

    describe 'app/decorators/your_model_decorator.rb' do
      subject { file('app/decorators/your_model_decorator.rb') }
      it { should exist }
      it { should contain "class YourModelDecorator < ApplicationDecorator" }
      it { should contain "decorates :your_model" }
    end
  end

  context 'decorator name' do
    before { run_generator ["YourModel"]  }

    describe 'spec/decorators/your_model_decorator_spec.rb' do
      subject { file('spec/decorators/your_model_decorator_spec.rb') }
      it { should exist }
      it { should contain "describe YourModelDecorator" }
    end
  end

  context 'default test framework' do
    before { run_generator ["YourModel"]  }

    describe 'spec/decorators/your_model_decorator_spec.rb' do
      subject { file('spec/decorators/your_model_decorator_spec.rb') }
      it { should exist }
      it { should contain "describe YourModelDecorator" }
    end
  end

  context 'using rspec' do
    before { run_generator ["YourModel", "-t=rspec"]  }

    describe 'spec/decorators/your_model_decorator_spec.rb' do
      subject { file('spec/decorators/your_model_decorator_spec.rb') }
      it { should exist }
      it { should contain "describe YourModelDecorator" }
    end
  end

  context 'using rspec' do
    before { run_generator ["YourModel", "-t=test_unit"]  }

    describe 'test/decorators/YourModel_decorator_test.rb' do
      subject { file('test/decorators/your_model_decorator_test.rb') }
      it { should exist }
      it { should contain "class YourModelDecoratorTest < ActiveSupport::TestCase" }
    end
  end
end


=begin
  describe 'no arguments' do
    before { run_generator %w(products)  }

    describe 'app/decorators/products_decorator.rb' do
      subject { file('app/decorators/products_decorator.rb') }
      it { should exist }
      it { should contain "class ProductsDecorator < ApplicationDecorator" }
    end
  end


  context 'simple' do
    before { run_generator %w(products)  }

    describe 'app/decorators/products_decorator.rb' do
      subject { file('app/decorators/products_decorator.rb') }
      it { should exist }
      it { should contain "class ProductsDecorator < ApplicationDecorator" }
    end
  end





  context 'using rspec' do

    describe 'app/decorators/products_decorator.rb' do
      subject { file('app/decorators/products_decorator.rb') }
      it { should exist }
      it { should contain "class ProductsDecorator < ApplicationDecorator" }
    end

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
=end
