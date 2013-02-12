require 'spec_helper'

describe Draper::CollectionDecorator do
  describe "#active_model_serializer" do
    it "returns ActiveModel::ArraySerializer" do
      collection_decorator = Draper::CollectionDecorator.new([])

      expect(collection_decorator.active_model_serializer).to be ActiveModel::ArraySerializer
    end
  end
end
