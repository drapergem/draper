require 'spec_helper'

module Draper
  describe HelperProxy do
    it "proxies methods to the view context" do
      view_context = double
      ViewContext.stub(current: view_context)
      helper_proxy = HelperProxy.new

      view_context.should_receive(:foo).with("bar")
      helper_proxy.foo("bar")
    end
  end
end
