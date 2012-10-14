require 'spec_helper'

describe Draper::HelperProxy do
  subject(:helper_proxy) { Draper::HelperProxy.new }
  let(:view_context) { Object.new }
  before { helper_proxy.stub(:view_context).and_return(view_context) }

  it "proxies methods to the view context" do
    view_context.should_receive(:foo).with("bar")
    helper_proxy.foo("bar")
  end
end
