require 'spec_helper'

module Draper
  describe DecoratedAssociation do
    describe "#initialize" do
      it "accepts valid options" do
        valid_options = {with: Decorator, scope: :foo, context: {}}
        expect{DecoratedAssociation.new(Decorator.new(Model.new), :association, valid_options)}.not_to raise_error
      end

      it "rejects invalid options" do
        expect{DecoratedAssociation.new(Decorator.new(Model.new), :association, foo: "bar")}.to raise_error ArgumentError, /Unknown key/
      end

      it "creates a factory" do
        options = {with: Decorator, context: {foo: "bar"}}

        expect(Factory).to receive(:new).with(options)
        DecoratedAssociation.new(double, :association, options)
      end

      describe ":with option" do
        it "defaults to nil" do
          expect(Factory).to receive(:new).with(with: nil, context: anything())
          DecoratedAssociation.new(double, :association, {})
        end
      end

      describe ":context option" do
        it "defaults to the identity function" do
          expect(Factory).to receive(:new) do |options|
            options[:context].call(:anything) == :anything
          end
          DecoratedAssociation.new(double, :association, {})
        end
      end
    end

    describe "#call" do
      it "calls the factory" do
        factory = double
        allow(Factory).to receive_messages(new: factory)
        associated = double
        owner_context = {foo: "bar"}
        object = double(association: associated)
        owner = double(object: object, context: owner_context)
        decorated_association = DecoratedAssociation.new(owner, :association, {})
        decorated = double

        expect(factory).to receive(:decorate).with(associated, context_args: owner_context).and_return(decorated)
        expect(decorated_association.call).to be decorated
      end

      it "memoizes" do
        factory = double
        allow(Factory).to receive_messages(new: factory)
        owner = double(object: double(association: double), context: {})
        decorated_association = DecoratedAssociation.new(owner, :association, {})
        decorated = double

        expect(factory).to receive(:decorate).once.and_return(decorated)
        expect(decorated_association.call).to be decorated
        expect(decorated_association.call).to be decorated
      end

      context "when the :scope option was given" do
        it "applies the scope before decoration" do
          factory = double
          allow(Factory).to receive_messages(new: factory)
          scoped = double
          object = double(association: double(applied_scope: scoped))
          owner = double(object: object, context: {})
          decorated_association = DecoratedAssociation.new(owner, :association, scope: :applied_scope)
          decorated = double

          expect(factory).to receive(:decorate).with(scoped, anything()).and_return(decorated)
          expect(decorated_association.call).to be decorated
        end
      end
    end
  end
end
