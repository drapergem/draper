require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/test_unit/decorator_generator'

describe TestUnit::DecoratorGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../tmp", __FILE__)

  before { prepare_destination }

  describe 'no arguments' do
    before { run_generator %w(products)  }

    describe 'test/decorators/products_decorator_test.rb' do
      subject { file('test/decorators/products_decorator_test.rb') }
      it { should exist }
      it { should contain "class ProductsDecoratorTest < ActiveSupport::TestCase" }
    end

  end
end
