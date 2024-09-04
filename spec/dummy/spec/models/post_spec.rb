require 'spec_helper'
require 'shared_examples/decoratable'

RSpec.describe Post do
  it_behaves_like 'a decoratable model'

  it { should be_a ApplicationRecord }

  describe 'broadcasts' do
    let(:modification) { described_class.create! }

    it 'passes a decorated object for rendering' do
      expect do
        modification
      end.to have_enqueued_job(Turbo::Streams::ActionBroadcastJob).with { |stream, action:, target:, **rendering|
        expect(rendering[:locals]).to include :post
        expect(rendering[:locals][:post]).to be_decorated
      }
    end
  end if defined? Turbo::Broadcastable
end
