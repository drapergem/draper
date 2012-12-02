require 'spec_helper'

describe Draper::Finders do
  describe ".find" do
    it "proxies to the model class" do
      Product.should_receive(:find).with(1)
      ProductDecorator.find(1)
    end

    it "decorates the result" do
      found = Product.new
      Product.stub(:find).and_return(found)
      decorator = ProductDecorator.find(1)
      decorator.should be_a ProductDecorator
      decorator.source.should be found
    end

    it "passes options to the decorator" do
      decorator = ProductDecorator.find(1, some: "options")
      decorator.options.should == {some: "options"}
    end
  end

  describe ".find_by_(x)" do
    it "proxies to the model class" do
      Product.should_receive(:find_by_name).with("apples")
      ProductDecorator.find_by_name("apples")
    end

    it "decorates the result" do
      found = Product.new
      Product.stub(:find_by_name).and_return(found)
      decorator = ProductDecorator.find_by_name("apples")
      decorator.should be_a ProductDecorator
      decorator.source.should be found
    end

    it "proxies complex finders" do
      Product.should_receive(:find_by_name_and_size).with("apples", "large")
      ProductDecorator.find_by_name_and_size("apples", "large")
    end

    it "proxies find_last_by_(x) finders" do
      Product.should_receive(:find_last_by_name_and_size).with("apples", "large")
      ProductDecorator.find_last_by_name_and_size("apples", "large")
    end

    it "proxies find_or_initialize_by_(x) finders" do
      Product.should_receive(:find_or_initialize_by_name_and_size).with("apples", "large")
      ProductDecorator.find_or_initialize_by_name_and_size("apples", "large")
    end

    it "proxies find_or_create_by_(x) finders" do
      Product.should_receive(:find_or_create_by_name_and_size).with("apples", "large")
      ProductDecorator.find_or_create_by_name_and_size("apples", "large")
    end

    it "passes options to the decorator" do
      Product.should_receive(:find_by_name_and_size).with("apples", "large", {some: "options"})
      decorator = ProductDecorator.find_by_name_and_size("apples", "large", some: "options")
      decorator.options.should == {some: "options"}
    end
  end

  describe ".find_all_by_" do
    it "proxies to the model class" do
      Product.should_receive(:find_all_by_name_and_size).with("apples", "large")
      ProductDecorator.find_all_by_name_and_size("apples", "large")
    end

    it "decorates the result" do
      found = [Product.new, Product.new]
      Product.stub(:find_all_by_name).and_return(found)
      decorator = ProductDecorator.find_all_by_name("apples")
      decorator.should be_a Draper::CollectionDecorator
      decorator.source.should be found
    end
  end

  describe ".all" do
    it "returns a decorated collection" do
      collection = ProductDecorator.all
      collection.should be_a Draper::CollectionDecorator
      collection.first.should be_a ProductDecorator
    end

    it "passes options to the collection decorator" do
      collection = ProductDecorator.all(some: "options")
      collection.options.should == {some: "options"}
    end
  end

  describe ".first" do
    it "proxies to the model class" do
      Product.should_receive(:first)
      ProductDecorator.first
    end

    it "decorates the result" do
      first = Product.new
      Product.stub(:first).and_return(first)
      decorator = ProductDecorator.first
      decorator.should be_a ProductDecorator
      decorator.source.should be first
    end

    it "passes options to the decorator" do
      decorator = ProductDecorator.first(some: "options")
      decorator.options.should == {some: "options"}
    end
  end

  describe ".last" do
    it "proxies to the model class" do
      Product.should_receive(:last)
      ProductDecorator.last
    end

    it "decorates the result" do
      last = Product.new
      Product.stub(:last).and_return(last)
      decorator = ProductDecorator.last
      decorator.should be_a ProductDecorator
      decorator.source.should be last
    end

    it "passes options to the decorator" do
      decorator = ProductDecorator.last(some: "options")
      decorator.options.should == {some: "options"}
    end
  end

  describe "scopes" do
    it "proxies to the model class" do
      Product.should_receive(:where).with({name: "apples"})
      ProductDecorator.where(name: "apples")
    end

    it "doesn't decorate the result" do
      found = [Product.new]
      Product.stub(:where).and_return(found)
      ProductDecorator.where(name: "apples").should be found
    end
  end
end
