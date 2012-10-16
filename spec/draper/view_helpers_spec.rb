require 'spec_helper'

describe Draper::ViewHelpers do
  let(:helper_proxy) { Draper::HelperProxy.new }
  let(:view_context) { Object.new }
  before { view_helpers.helpers.stub(:view_context).and_return(view_context) }

  subject { Class.new { include Draper::ViewHelpers } }
  let(:view_helpers) { subject.new }

  describe "#helpers" do
    it "returns a HelperProxy" do
      view_helpers.helpers.should be_a Draper::HelperProxy
    end

    it "is aliased to #h" do
      view_helpers.h.should be subject.helpers
    end
  end

  it "delegates #localize to #helpers" do
    view_context.should_receive(:localize).with(Date.new)
    view_helpers.localize(Date.new)
  end

  it "aliases #l to #localize" do
    view_context.should_receive(:localize).with(Date.new)
    view_helpers.l(Date.new)
  end

  describe ".helpers" do
    it "returns a HelperProxy" do
      subject.helpers.should be_a Draper::HelperProxy
    end

    it "is aliased to #h" do
      subject.h.should be subject.helpers
    end
  end

end
