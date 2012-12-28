require 'spec_helper'

describe Post do
  describe "#==" do
    before { Post.create }
    subject { Post.first }

    it "is true for other instances' decorators" do
      other = Post.first
      subject.should_not be other
      (subject == other.decorate).should be_true
    end
  end
end
