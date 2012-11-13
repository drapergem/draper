require 'spec_helper'

RSpec::Matchers.define :allow do |method|
  match do |subject|
    subject.allow?(method)
  end
end

describe Draper::Security do
  subject(:security) { Draper::Security.new }

  context "when newly initialized" do
    it "allows any method" do
      security.should allow :foo
    end
  end

  describe "#denies" do
    it "raises an error when there are no arguments" do
      expect{security.denies}.to raise_error ArgumentError
    end
  end

  context "when using denies" do
    before { security.denies :foo, :bar }

    it "denies the listed methods" do
      security.should_not allow :foo
      security.should_not allow :bar
    end

    it "allows other methods" do
      security.should allow :baz
    end

    it "accepts multiple denies" do
      expect{security.denies :baz}.not_to raise_error
    end

    it "does not accept denies_all" do
      expect{security.denies_all}.to raise_error ArgumentError
    end

    it "does not accept allows" do
      expect{security.allows :baz}.to raise_error ArgumentError
    end

    context "when using mulitple denies" do
      before { security.denies :baz }

      it "still denies the original methods" do
        security.should_not allow :foo
        security.should_not allow :bar
      end

      it "denies the additional methods" do
        security.should_not allow :baz
      end

      it "allows other methods" do
        security.should allow :qux
      end
    end

    context "with strings" do
      before { security.denies "baz" }

      it "denies the method" do
        security.should_not allow :baz
      end
    end
  end

  context "when using denies_all" do
    before { security.denies_all }

    it "denies all methods" do
      security.should_not allow :foo
    end

    it "accepts multiple denies_all" do
      expect{security.denies_all}.not_to raise_error
    end

    it "does not accept denies" do
      expect{security.denies :baz}.to raise_error ArgumentError
    end

    it "does not accept allows" do
      expect{security.allows :baz}.to raise_error ArgumentError
    end

    context "when using mulitple denies_all" do
      before { security.denies_all }

      it "still denies all methods" do
        security.should_not allow :foo
      end
    end
  end

  describe "#allows" do
    it "raises an error when there are no arguments" do
      expect{security.allows}.to raise_error ArgumentError
    end
  end

  context "when using allows" do
    before { security.allows :foo, :bar }

    it "allows the listed methods" do
      security.should allow :foo
      security.should allow :bar
    end

    it "denies other methods" do
      security.should_not allow :baz
    end

    it "accepts multiple allows" do
      expect{security.allows :baz}.not_to raise_error
    end

    it "does not accept denies" do
      expect{security.denies :baz}.to raise_error ArgumentError
    end

    it "does not accept denies_all" do
      expect{security.denies_all}.to raise_error ArgumentError
    end

    context "when using mulitple allows" do
      before { security.allows :baz }

      it "still allows the original methods" do
        security.should allow :foo
        security.should allow :bar
      end

      it "allows the additional methods" do
        security.should allow :baz
      end

      it "denies other methods" do
        security.should_not allow :qux
      end
    end

    context "with strings" do
      before { security.allows "baz" }

      it "allows the method" do
        security.should allow :baz
      end
    end
  end

end
