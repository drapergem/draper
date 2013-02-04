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
      protect_class HelperProxy

      it "proxies methods to the view context" do
        view_context = double
        helper_proxy = HelperProxy.new(view_context)

        view_context.stub(:foo).and_return{|arg| arg}
        expect(helper_proxy.foo(:passed)).to be :passed
      end

      it "passes blocks" do
        view_context = double
        helper_proxy = HelperProxy.new(view_context)

        view_context.stub(:foo).and_return{|&block| block.call}
        expect(helper_proxy.foo{:yielded}).to be :yielded
      end

      it "defines the method for better performance" do
        helper_proxy = HelperProxy.new(double(foo: "bar"))

        expect(HelperProxy.instance_methods).not_to include :foo
        helper_proxy.foo
        expect(HelperProxy.instance_methods).to include :foo
      end
    end

    describe "proxying methods which are overriding" do
      it "proxies :capture" do
        view_context = double
        helper_proxy = HelperProxy.new(view_context)

        view_context.stub(:capture).and_return{|*args, &block| [*args, block.call] }
        expect(helper_proxy.capture(:first_arg, :second_arg){:yielded}).to \
          be_eql [:first_arg, :second_arg, :yielded]
      end
    end
  end
end
