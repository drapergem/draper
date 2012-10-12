require 'spec_helper'

describe Draper::Security do
  subject(:security) { Draper::Security.new }

  context "when newly initialized" do
    it "allows any method" do
      security.allow?(:foo).should be_true
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
      security.allow?(:foo).should be_false
      security.allow?(:bar).should be_false
    end

    it "allows other methods" do
      security.allow?(:baz).should be_true
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
        security.allow?(:foo).should be_false
        security.allow?(:bar).should be_false
      end

      it "denies the additional methods" do
        security.allow?(:baz).should be_false
      end

      it "allows other methods" do
        security.allow?(:qux).should be_true
      end
    end
  end

  context "when using denies_all" do
    before { security.denies_all }

    it "denies all methods" do
      security.allow?(:foo).should be_false
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
        security.allow?(:foo).should be_false
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
      security.allow?(:foo).should be_true
      security.allow?(:bar).should be_true
    end

    it "denies other methods" do
      security.allow?(:baz).should be_false
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
        security.allow?(:foo).should be_true
        security.allow?(:bar).should be_true
      end

      it "allows the additional methods" do
        security.allow?(:baz).should be_true
      end

      it "denies other methods" do
        security.allow?(:qux).should be_false
      end
    end
  end

end
