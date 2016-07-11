require 'spec_helper'

module Draper
  describe Finders do
    protect_class ProductDecorator
    before { ProductDecorator.decorates_finders }

    describe ".find" do
      it "proxies to the model class" do
        expect(Product).to receive(:find).with(1)
        ProductDecorator.find(1)
      end

      it "decorates the result" do
        found = Product.new
        allow(Product).to receive(:find).and_return(found)
        decorator = ProductDecorator.find(1)
        expect(decorator).to be_a ProductDecorator
        expect(decorator.object).to be found
      end

      it "passes context to the decorator" do
        allow(Product).to receive(:find)
        context = {some: "context"}
        decorator = ProductDecorator.find(1, context: context)

        expect(decorator.context).to be context
      end
    end

    describe ".find_by_(x)" do
      it "proxies to the model class" do
        expect(Product).to receive(:find_by_name).with("apples")
        ProductDecorator.find_by_name("apples")
      end

      it "decorates the result" do
        found = Product.new
        allow(Product).to receive(:find_by_name).and_return(found)
        decorator = ProductDecorator.find_by_name("apples")
        expect(decorator).to be_a ProductDecorator
        expect(decorator.object).to be found
      end

      it "proxies complex ProductDecorators" do
        expect(Product).to receive(:find_by_name_and_size).with("apples", "large")
        ProductDecorator.find_by_name_and_size("apples", "large")
      end

      it "proxies find_last_by_(x) ProductDecorators" do
        expect(Product).to receive(:find_last_by_name_and_size).with("apples", "large")
        ProductDecorator.find_last_by_name_and_size("apples", "large")
      end

      it "proxies find_or_initialize_by_(x) ProductDecorators" do
        expect(Product).to receive(:find_or_initialize_by_name_and_size).with("apples", "large")
        ProductDecorator.find_or_initialize_by_name_and_size("apples", "large")
      end

      it "proxies find_or_create_by_(x) ProductDecorators" do
        expect(Product).to receive(:find_or_create_by_name_and_size).with("apples", "large")
        ProductDecorator.find_or_create_by_name_and_size("apples", "large")
      end

      it "passes context to the decorator" do
        allow(Product).to receive(:find_by_name_and_size)
        context = {some: "context"}
        decorator = ProductDecorator.find_by_name_and_size("apples", "large", context: context)

        expect(decorator.context).to be context
      end
    end

    describe ".find_all_by_" do
      it "proxies to the model class" do
        expect(Product).to receive(:find_all_by_name_and_size).with("apples", "large").and_return([])
        ProductDecorator.find_all_by_name_and_size("apples", "large")
      end

      it "decorates the result" do
        found = [Product.new, Product.new]
        allow(Product).to receive(:find_all_by_name).and_return(found)
        decorator = ProductDecorator.find_all_by_name("apples")

        expect(decorator).to be_a Draper::CollectionDecorator
        expect(decorator.decorator_class).to be ProductDecorator
        expect(decorator).to eq found
      end

      it "passes context to the decorator" do
        allow(Product).to receive(:find_all_by_name)
        context = {some: "context"}
        decorator = ProductDecorator.find_all_by_name("apples", context: context)

        expect(decorator.context).to be context
      end
    end

    describe ".all" do
      it "returns a decorated collection" do
        found = [Product.new, Product.new]
        allow(Product).to receive_messages all: found
        decorator = ProductDecorator.all

        expect(decorator).to be_a Draper::CollectionDecorator
        expect(decorator.decorator_class).to be ProductDecorator
        expect(decorator).to eq found
      end

      it "passes context to the decorator" do
        allow(Product).to receive(:all)
        context = {some: "context"}
        decorator = ProductDecorator.all(context: context)

        expect(decorator.context).to be context
      end
    end

    describe ".first" do
      it "proxies to the model class" do
        expect(Product).to receive(:first)
        ProductDecorator.first
      end

      it "decorates the result" do
        first = Product.new
        allow(Product).to receive(:first).and_return(first)
        decorator = ProductDecorator.first
        expect(decorator).to be_a ProductDecorator
        expect(decorator.object).to be first
      end

      it "passes context to the decorator" do
        allow(Product).to receive(:first)
        context = {some: "context"}
        decorator = ProductDecorator.first(context: context)

        expect(decorator.context).to be context
      end
    end

    describe ".last" do
      it "proxies to the model class" do
        expect(Product).to receive(:last)
        ProductDecorator.last
      end

      it "decorates the result" do
        last = Product.new
        allow(Product).to receive(:last).and_return(last)
        decorator = ProductDecorator.last
        expect(decorator).to be_a ProductDecorator
        expect(decorator.object).to be last
      end

      it "passes context to the decorator" do
        allow(Product).to receive(:last)
        context = {some: "context"}
        decorator = ProductDecorator.last(context: context)

        expect(decorator.context).to be context
      end
    end

  end
end
