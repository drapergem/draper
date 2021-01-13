require 'spec_helper'
require 'dummy/config/environment'
require 'ammeter/init'
require 'generators/rails/decorator_generator'

describe Rails::Generators::DecoratorGenerator do
  destination File.expand_path("../tmp", __FILE__)

  before { prepare_destination }
  after(:all) { FileUtils.rm_rf destination_root }

  describe "the generated decorator" do
    subject { file("app/decorators/your_model_decorator.rb") }

    describe "naming" do
      before { run_generator %w(YourModel) }

      it { is_expected.to contain "class YourModelDecorator" }
    end

    describe "namespacing" do
      subject { file("app/decorators/namespace/your_model_decorator.rb") }
      before { run_generator %w(Namespace::YourModel) }

      it { is_expected.to contain "class Namespace::YourModelDecorator" }
    end

    describe "inheritance" do
      context "by default" do
        before { run_generator %w(YourModel) }

        it { is_expected.to contain "class YourModelDecorator < Draper::Decorator" }
      end

      context "with the --parent option" do
        before { run_generator %w(YourModel --parent=FooDecorator) }

        it { is_expected.to contain "class YourModelDecorator < FooDecorator" }
      end

      context "with an ApplicationDecorator" do
        before do
          allow_any_instance_of(Object).to receive(:require).and_call_original
          allow_any_instance_of(Object).to receive(:require).with("application_decorator").and_return(
            stub_const "ApplicationDecorator", Class.new
          )
        end

        before { run_generator %w(YourModel) }

        it { is_expected.to contain "class YourModelDecorator < ApplicationDecorator" }
      end
    end
  end

  context "with -t=rspec" do
    describe "the generated spec" do
      subject { file("spec/decorators/your_model_decorator_spec.rb") }

      describe "naming" do
        before { run_generator %w(YourModel -t=rspec) }

        it { is_expected.to contain "describe YourModelDecorator" }
      end

      describe "namespacing" do
        subject { file("spec/decorators/namespace/your_model_decorator_spec.rb") }
        before { run_generator %w(Namespace::YourModel -t=rspec) }

        it { is_expected.to contain "describe Namespace::YourModelDecorator" }
      end
    end
  end

  context "with -t=test_unit" do
    describe "the generated test" do
      subject { file("test/decorators/your_model_decorator_test.rb") }

      describe "naming" do
        before { run_generator %w(YourModel -t=test_unit) }

        it { is_expected.to contain "class YourModelDecoratorTest < Draper::TestCase" }
      end

      describe "namespacing" do
        subject { file("test/decorators/namespace/your_model_decorator_test.rb") }
        before { run_generator %w(Namespace::YourModel -t=test_unit) }

        it { is_expected.to contain "class Namespace::YourModelDecoratorTest < Draper::TestCase" }
      end
    end
  end
end
