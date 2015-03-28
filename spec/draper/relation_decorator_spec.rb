require 'spec_helper'
require 'support/shared_examples/view_helpers'

module Draper
  describe RelationDecorator do
    it_behaves_like "view helpers", RelationDecorator.new([])

    describe "#initialize" do
      describe "options validation" do

        it "does not raise error on valid options" do
          valid_options = {with: Decorator, context: {}}
          expect{RelationDecorator.new(ActiveRecord::Relation.new, valid_options)}.not_to raise_error
        end

        it "raises error on invalid options" do
          expect{RelationDecorator.new(ActiveRecord::Relation.new, foo: "bar")}.to raise_error ArgumentError, /Unknown key/
        end
      end
    end

    context "with context" do
      it "stores the context itself" do
        context = {some: "context"}
        decorator = RelationDecorator.new(ActiveRecord::Relation.new, context: context)

        expect(decorator.context).to be context
      end
    end

    describe "#context=" do
      it "updates the stored context" do
        decorator = RelationDecorator.new(ActiveRecord::Relation.new, context: {some: "context"})
        new_context = {other: "context"}

        decorator.context = new_context
        expect(decorator.context).to be new_context
      end
    end

    it "returns a relation decorator when a scope is called on the decorated relation" do
      module ActiveRecord
        class Relation
          include Draper::Decoratable
          def some_scope; self ;end
        end
      end

      klass = Product
      klass.class_eval { def self.some_scope ; ActiveRecord::Relation.new ; end }
      expect(Product).to respond_to(:some_scope)
      proxy = RelationDecorator.new(klass)
      expect(proxy.some_scope).to be_instance_of(proxy.class)
    end

    it 'supports chaining multiple scopes' do
      module ActiveRecord
        class Relation
          include Draper::Decoratable
          def some_scope; self ;end
        end
      end

      klass = Product
      klass.class_eval { def self.some_scope ; ActiveRecord::Relation.new ; end }
      proxy = RelationDecorator.new(klass)
      expect(proxy.some_scope.some_scope.some_scope).to be_instance_of(proxy.class)
      expect(proxy.some_scope.some_scope.some_scope).to be_decorated
    end

    describe '#decorated?' do
      it 'returns true' do
        klass = Product
        klass.class_eval { def self.some_scope ; ActiveRecord::Relation.new ; end }
        decorator = ProductsRelationDecorator.new(Product.some_scope)

        expect(decorator).to be_decorated
      end
    end

    describe '#decorated_with?' do
      it "checks if a decorator has been applied to a collection" do
        klass = Product
        klass.class_eval { def self.some_scope ; ActiveRecord::Relation.new ; end }
        decorator = ProductsRelationDecorator.new(Product.some_scope)

        expect(decorator).to be_decorated_with ProductsRelationDecorator
        expect(decorator).not_to be_decorated_with OtherDecorator
      end
    end
  end
end