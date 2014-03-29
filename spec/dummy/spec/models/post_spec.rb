require 'spec_helper'
require 'shared_examples/decoratable'

describe Post do
  it_behaves_like "a decoratable model"

  it 'correctly decorates on top of the scopes' do
    Post.create
    relation = Post.limit(1).decorate
    expect(relation).to be_decorated_with Draper::RelationDecorator
    expect(relation.first).to be_decorated_with PostDecorator
    expect(relation.first).to be_a(Post)
  end

  it 'also supports interchanging scope order' do
    Post.create
    relation = Post.decorate.limit(1)
    expect(relation).to be_decorated_with Draper::RelationDecorator
    expect(relation.first).to be_decorated_with PostDecorator
    expect(relation.first).to be_a(Post)
  end

  it 'works with in_groups_of' do
    3.times { Post.create }
    Post.decorate.in_groups_of(3, false) do |group|
      expect(group.first).to be_decorated_with PostDecorator
    end
  end
end
