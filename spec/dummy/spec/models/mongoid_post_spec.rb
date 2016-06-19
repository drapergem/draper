require 'spec_helper'
require 'shared_examples/decoratable'

if defined?(Mongoid)
  describe MongoidPost do
    it_behaves_like "a decoratable model"

    it 'correctly decorates on top of the criteria' do
      MongoidPost.create
      relation = MongoidPost.limit(1).decorate
      expect(relation).to be_decorated_with Draper::RelationDecorator
      expect(relation.first).to be_decorated_with MongoidPostDecorator
      expect(relation.first).to be_a(MongoidPost)
    end

    it 'also supports interchanging scope order' do
      MongoidPost.create
      relation = MongoidPost.decorate.limit(1)
      expect(relation).to be_decorated_with Draper::RelationDecorator
      expect(relation.first).to be_decorated_with MongoidPostDecorator
      expect(relation.first).to be_a(MongoidPost)
    end

    it 'works with in_groups_of' do
      3.times { MongoidPost.create }
      MongoidPost.decorate.in_groups_of(3, false) do |group|
        expect(group.first).to be_decorated_with MongoidPostDecorator
      end
    end
  end
end
