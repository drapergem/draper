require_relative '../rails_helper'

RSpec.describe Draper::CollectionDecorator do
  describe "#active_model_serializer" do
    it "returns ActiveModel::Serializer::CollectionSerializer" do
      collection_decorator  = Draper::CollectionDecorator.new([])
      collection_serializer = ActiveModel::Serializer.serializer_for(collection_decorator)

      expect(collection_serializer).to be ActiveModel::Serializer::CollectionSerializer
    end
  end
end
