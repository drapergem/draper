require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/rspec/decorator_generator'

describe Rspec::DecoratorGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../tmp", __FILE__)

  before { prepare_destination }

  describe 'no arguments' do
    before { run_generator %w(products)  }

    describe 'spec/decorators/products_decorator_spec.rb' do
      subject { file('spec/decorators/products_decorator_spec.rb') }
      it { should exist }
      it { should contain "describe ProductsDecorator" }
    end

  end
end
