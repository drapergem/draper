require 'spec_helper'
require_relative '../dummy/app/decorators/post_decorator'

Post = Struct.new(:id) { }

module Draper
  describe QueryMethods do
    let(:fake_strategy) { instance_double(QueryMethods::LoadStrategy::ActiveRecord) }

    before { allow(QueryMethods::LoadStrategy).to receive(:new).and_return(fake_strategy) }

    describe '#method_missing' do
      let(:collection) { [ Post.new, Post.new ] }
      let(:collection_context) { { user: 'foo' } }
      let(:collection_decorator) { PostDecorator.decorate_collection(collection, context: collection_context) }

      context 'when strategy allows collection to call the method' do
        let(:results) { spy(:results) }

        before do
          allow(fake_strategy).to receive(:allowed?).with(:some_query_method).and_return(true)
          allow(collection).to receive(:send).with(:some_query_method).and_return(results)
        end

        it 'calls the method on the collection and decorate it results' do
          collection_decorator.some_query_method

          expect(results).to have_received(:decorate)
        end

        it 'calls the method on the collection and keeps the decoration options' do
          collection_decorator.some_query_method

          expect(results).to have_received(:decorate).with({ context: collection_context, with: PostDecorator })
        end
      end

      context 'when strategy does not allow collection to call the method' do
        before { allow(fake_strategy).to receive(:allowed?).with(:some_query_method).and_return(false) }

        it 'raises NoMethodError' do
          expect { collection_decorator.some_query_method }.to raise_exception(NoMethodError)
        end
      end
    end

    describe "#respond_to?" do
      let(:collection) { [ Post.new, Post.new ] }
      let(:collection_decorator) { PostDecorator.decorate_collection(collection) }

      subject { collection_decorator.respond_to?(:some_query_method) }

      context 'when strategy allows collection to call the method' do
        before do
          allow(fake_strategy).to receive(:allowed?).with(:some_query_method).and_return(true)
        end

        it { is_expected.to eq(true) }
      end

      context 'when strategy does not allow collection to call the method' do
        before do
          allow(fake_strategy).to receive(:allowed?).with(:some_query_method).and_return(false)
        end

        it { is_expected.to eq(false) }
      end
    end
  end
end
