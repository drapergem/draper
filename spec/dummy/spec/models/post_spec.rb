require 'spec_helper'

describe Post do
  describe "#==" do
    it "is true for other instances' decorators" do
      Post.create
      one = Post.first
      other = Post.first

      expect(one).not_to be other
      expect(one == other.decorate).to be_true
    end
  end
end
