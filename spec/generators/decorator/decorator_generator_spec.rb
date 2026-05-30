require 'spec_helper'
require 'dummy/config/environment'
require 'ammeter/init'
require 'generators/rails/decorator_generator'

describe Rails::Generators::DecoratorGenerator do
  destination Rails.root / 'tmp/generated'

  subject { file path }

  let(:model_name)     { 'YourModel' }
  let(:decorator_name) { "#{model_name}Decorator" }
  let(:options)        { {} }
  let(:args)           { options.map { |k, v| "--#{k.to_s.dasherize}=#{v}" } }

  before { prepare_destination }
  before { run_generator [model_name, *args] }

  shared_context :namespaceable do
    let(:model_name) { 'Namespace::YourModel' }

    include_examples :naming
  end

  describe "decorator class" do
    let(:path) { "app/decorators/#{decorator_name.underscore}.rb" }

    it { is_expected.to have_correct_syntax }

    shared_examples :naming do
      it 'is properly named' do
        is_expected.to exist
        is_expected.to contain "class #{decorator_name}"
      end
    end

    include_examples :naming
    it_behaves_like  :namespaceable

    describe "inheritance" do
      let(:parent) { 'Draper::Decorator' }

      shared_examples :inheritance do
        it { is_expected.to contain "class #{decorator_name} < #{parent}" }
      end

      include_examples :inheritance

      context "with --parent" do
        let(:options) { { parent: 'FooDecorator' } }
        let(:parent)  { options[:parent] }

        include_examples :inheritance
      end

      context "with an ApplicationDecorator" do
        let(:parent) { 'ApplicationDecorator' }

        let :options do # HACK: run before the generator
          allow_any_instance_of(Object).to receive(:require).and_call_original
          allow_any_instance_of(Object).to receive(:require).with("application_decorator").and_return(
            stub_const "ApplicationDecorator", Class.new
          )
          super()
        end

        include_examples :inheritance
      end
    end
  end

  describe "spec" do
    let(:options) { { test_framework: :rspec } }
    let(:path)    { "spec/decorators/#{decorator_name.underscore}_spec.rb" }

    it { is_expected.to have_correct_syntax }

    shared_examples :naming do
      it 'is properly named' do
        is_expected.to exist
        is_expected.to contain "describe #{decorator_name}"
      end
    end

    include_examples :naming
    it_behaves_like  :namespaceable
  end

  describe "test" do
    let(:options) { { test_framework: :test_unit } }
    let(:path)    { "test/decorators/#{decorator_name.underscore}_test.rb" }

    it { is_expected.to have_correct_syntax }

    shared_examples :naming do
      it 'is properly named' do
        is_expected.to exist
        is_expected.to contain "class #{decorator_name}Test < Draper::TestCase"
      end
    end

    include_examples :naming
    it_behaves_like  :namespaceable
  end
end
