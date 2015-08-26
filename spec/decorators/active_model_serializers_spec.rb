require 'spec_helper'

describe Draper::CollectionDecorator do
  describe "#active_model_serializer" do
    it "returns ActiveModel::ArraySerializer" do
      collection_decorator = Draper::CollectionDecorator.new([])
      if defined?(ActiveModel::ArraySerializerSupport)
        collection_serializer = collection_decorator.active_model_serializer
      else
        collection_serializer = ActiveModel::Serializer.serializer_for(collection_decorator)
      end

      expect(collection_serializer).to be ActiveModel::ArraySerializer
    end
  end
end
