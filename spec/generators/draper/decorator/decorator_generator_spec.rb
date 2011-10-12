require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/drapper/decorator/decorator_generator'

describe Drapper::DecoratorGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  describe 'no arguments' do
    before { run_generator %w(products)  }

    describe 'app/decorators/application_decorator.rb' do
      subject { file('app/decorators/application_decorator.rb') }
      it { should exist }
      it { should contain "class ApplicationDecorator < Drapper::Base" }
    end

    describe 'app/decorators/products_decorator.rb' do
      subject { file('app/decorators/products_decorator.rb') }
      it { should exist }
      it { should contain "class ProductsDecorator < ApplicationDecorator" }
    end

  end
end
