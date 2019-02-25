require 'spec_helper'
require_relative '../dummy/app/decorators/post_decorator'

Post = Struct.new(:id) { }

module Draper
  describe QueryMethods do
    describe '#method_missing' do
      let(:collection) { [ Post.new, Post.new ] }
      let(:collection_decorator) { PostDecorator.decorate_collection(collection) }
      let(:fake_strategy) { instance_double(QueryMethods::LoadStrategy::ActiveRecord) }

      before { allow(QueryMethods::LoadStrategy).to receive(:new).and_return(fake_strategy) }

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
      end

      context 'when strategy does not allow collection to call the method' do
        before { allow(fake_strategy).to receive(:allowed?).with(:some_query_method).and_return(false) }

        it 'raises NoMethodError' do
          expect { collection_decorator.some_query_method }.to raise_exception(NoMethodError)
        end
      end
    end
  end
end
