require 'spec_helper'
require 'shared_examples/decoratable'

RSpec.describe Post do
  it_behaves_like 'a decoratable model'

  it { should be_a ApplicationRecord }

  describe '#to_global_id' do
    let(:post) { Post.create }
    subject { post.to_global_id }

    it { is_expected.to eq post.decorate.to_global_id }
  end
end
