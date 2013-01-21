require 'spec_helper'

if defined?(Mongoid)
  describe MongoidPost do
    it "is decoratable" do
      expect(MongoidPost).to respond_to :decorator_class
      expect(MongoidPost.new).to respond_to :decorate
    end
  end
end
