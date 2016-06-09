require 'spec_helper'

module Draper
  describe LazyHelpers do
    describe "#method_missing" do
      let(:decorator) do
        Struct.new(:helpers){include Draper::LazyHelpers}.new(double)
      end

      it "proxies methods to #helpers" do
        allow(decorator.helpers).to receive(:foo) { |arg| arg }
        expect(decorator.foo(:passed)).to be :passed
      end

      it "passes blocks" do
        allow(decorator.helpers).to receive(:foo) { |&block| block.call }
        expect(decorator.foo{:yielded}).to be :yielded
      end
    end
  end
end
