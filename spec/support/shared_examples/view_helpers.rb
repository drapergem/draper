require 'spec_helper'

RSpec.shared_examples_for "view helpers" do |subject|
  describe "#helpers" do
    it "returns the current view context" do
      allow(Draper::ViewContext).to receive(:current) { :current_view_context }
      # Draper::ViewContext.stub current: :current_view_context
      expect(subject.helpers).to be :current_view_context
    end

    it "is aliased to #h" do
      # Draper::ViewContext.stub current: :current_view_context
      allow(Draper::ViewContext).to receive(:current) { :current_view_context }
      expect(subject.h).to be :current_view_context
    end
  end

  describe "#localize" do
    let(:helpers) { double }

    before :each do
      allow(subject).to receive(:helpers) { helpers }
      allow(helpers).to receive(:localize)
    end

    it "delegates to #helpers" do
      expect(helpers).to receive(:localize).with(:an_object, some: "parameter")
      subject.localize(:an_object, some: "parameter")
    end

    it "is aliased to #l" do
      expect(helpers).to receive(:localize).with(:an_object, some: 'parameter')
      subject.l(:an_object, some: "parameter")
    end
  end

  describe ".helpers" do
    it "returns the current view context" do
      allow(Draper::ViewContext).to receive(:current) { :current_view_context }
      # Draper::ViewContext.stub current: :current_view_context
      expect(subject.class.helpers).to be :current_view_context
    end

    it "is aliased to .h" do
      allow(Draper::ViewContext).to receive(:current) { :current_view_context }
      # Draper::ViewContext.stub current: :current_view_context
      expect(subject.class.h).to be :current_view_context
    end
  end
end
