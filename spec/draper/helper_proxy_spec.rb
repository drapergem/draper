require 'spec_helper'

module Draper
  describe HelperProxy do
    describe "#initialize" do
      it "sets the view context" do
        view_context = double
        helper_proxy = HelperProxy.new(view_context)

        expect(helper_proxy.send(:view_context)).to be view_context
      end
    end

    describe "#method_missing" do
      it "proxies methods to the view context" do
        view_context = double
        helper_proxy = HelperProxy.new(view_context)

        view_context.should_receive(:foo).with("bar")
        helper_proxy.foo("bar")
      end
    end
  end
end
