require 'spec_helper'
require 'ammeter/init'

# Generators are not automatically loaded by Rails
require 'generators/decorator/decorator_generator'

describe Rails::Generators::DecoratorGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  context 'decorator context' do
    before { run_generator ["YourModel"]  }

    describe 'app/decorators/your_model_decorator.rb' do
      subject { file('app/decorators/your_model_decorator.rb') }
      it { should exist }
      it { should contain "class YourModelDecorator < Draper::Decorator" }
    end
  end

  context 'decorator name' do
    before { run_generator ["YourModel", '-t=rspec']  }

    describe 'spec/decorators/your_model_decorator_spec.rb' do
      subject { file('spec/decorators/your_model_decorator_spec.rb') }
      it { should exist }
      it { should contain "describe YourModelDecorator" }
    end
  end

  context 'parent decorator' do
    describe 'decorator inherited from Draper::Decorator' do
      before { run_generator ["YourModel"] }

      subject { file('app/decorators/your_model_decorator.rb') }
      it { should exist }
      it { should contain "class YourModelDecorator < Draper::Decorator" }
    end

    describe "decorator inherited from ApplicationDecorator if it's present" do
      before do
       class ApplicationDecorator; end
       run_generator ["YourModel"]
      end

      after do
        Object.send(:remove_const, :ApplicationDecorator)
      end

      subject { file('app/decorators/your_model_decorator.rb') }
      it { should exist }
      it { should contain "class YourModelDecorator < ApplicationDecorator" }
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

  context 'using rspec with namespaced model' do
    before { run_generator ["Namespace::YourModel", "-t=rspec"]  }

    describe 'spec/decorators/your_model_decorator_spec.rb' do
      subject { file('spec/decorators/namespace/your_model_decorator_spec.rb') }
      it { should exist }
      it { should contain "describe Namespace::YourModelDecorator" }
    end
  end

  context 'using test-unit' do
    before { run_generator ["YourModel", "-t=test_unit"]  }

    describe 'test/decorators/YourModel_decorator_test.rb' do
      subject { file('test/decorators/your_model_decorator_test.rb') }
      it { should exist }
      it { should contain "class YourModelDecoratorTest < Draper::TestCase" }
    end
  end

  context 'using test-unit with namespaced model' do
    before { run_generator ["Namespace::YourModel", "-t=test_unit"]  }

    describe 'test/decorators/your_model_decorator_test.rb' do
      subject { file('test/decorators/namespace/your_model_decorator_test.rb') }
      it { should exist }
      it { should contain "class Namespace::YourModelDecoratorTest < Draper::TestCase" }
    end
  end

  context 'using minitest-rails' do
    before { run_generator ["YourModel", "-t=mini_test"] }

    describe 'test/decorators/your_model_decorator_test.rb' do
      subject { file('test/decorators/your_model_decorator_test.rb') }
      it { should exist }
      it { should contain "class YourModelDecoratorTest < Draper::TestCase" }
    end
  end

  context 'using minitest-rails with namespaced model' do
    before { run_generator ["Namespace::YourModel", "-t=mini_test"] }

    describe 'test/decorators/your_model_decorator_test.rb' do
      subject { file('test/decorators/namespace/your_model_decorator_test.rb') }
      it { should exist }
      it { should contain "class Namespace::YourModelDecoratorTest < Draper::TestCase" }
    end
  end

  context 'using minitest-rails with spec syntax' do
    before { run_generator ["YourModel", "-t=mini_test", "--spec"] }

    describe 'test/decorators/your_model_decorator_test.rb' do
      subject { file('test/decorators/your_model_decorator_test.rb') }
      it { should exist }
      it { should contain "describe YourModelDecorator" }
    end
  end

  context 'using minitest-rails with spec syntax with namespaced model' do
    before { run_generator ["Namespace::YourModel", "-t=mini_test", "--spec"] }

    describe 'test/decorators/your_model_decorator_test.rb' do
      subject { file('test/decorators/namespace/your_model_decorator_test.rb') }
      it { should exist }
      it { should contain "describe Namespace::YourModelDecorator" }
    end
  end

end
