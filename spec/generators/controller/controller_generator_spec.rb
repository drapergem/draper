require 'spec_helper'
require 'dummy/config/environment'
require 'ammeter/init'
require 'generators/controller_override'
require 'generators/rails/decorator_generator'
SimpleCov.command_name 'test:generator'

describe Rails::Generators do
  destination Rails.root / 'tmp/generated'

  subject { file path }

  let(:controller_name) { 'YourModels' }
  let(:model_name)      { controller_name.singularize }
  let(:decorator_name)  { "#{model_name}Decorator" }
  let(:options)         { {} }
  let(:args)            { options.map { |k, v| "--#{k.to_s.dasherize}=#{v}" } }

  before { prepare_destination }
  before { run_generator [controller_name, *args] }

  shared_context :namespaceable do
    let(:controller_name) { 'Namespace::YourModels' }
    let(:model_name)      { options[:model_name] or super() }

    include_examples :naming

    context "with the same namespace" do
      let(:options) { super().merge model_name: 'Namespace::OtherModel' }

      include_examples :naming
    end

    context "with another namespace" do
      let(:options) { super().merge model_name: 'OtherNamespace::YourModel' }

      include_examples :naming
    end

    context "without namespace" do
      let(:options) { super().merge model_name: 'YourModel' }

      include_examples :naming
    end
  end

  describe "decorator class" do
    let(:path) { "app/decorators/#{decorator_name.underscore}.rb" }

    shared_examples :naming do
      it 'is properly named' do
        is_expected.to exist
        is_expected.to contain "class #{decorator_name}"
      end
    end

    describe Rails::Generators::ControllerGenerator do
      include_examples :naming
      it_behaves_like :namespaceable
    end

    describe Rails::Generators::ScaffoldControllerGenerator do
      let(:options) { { skip_routes: true } }

      include_examples :naming
      it_behaves_like :namespaceable
    end
  end
end
