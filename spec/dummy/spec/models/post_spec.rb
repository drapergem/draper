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
end
