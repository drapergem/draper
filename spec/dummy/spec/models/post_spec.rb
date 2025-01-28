require 'rails_helper'
require 'shared_examples/decoratable'

RSpec.describe Post do
  let(:record) { described_class.create! }

  it_behaves_like 'a decoratable model'

  it { should be_a ApplicationRecord }

  describe 'associations' do
    context 'when decorated' do
      subject { associated.decorate }

      let(:associated) { record.comments }
      let(:persisted)  { associated.create! [{}] * rand(0..2) }
      let(:unsaved)    { associated.build   [{}] * rand(1..2) }

      before { persisted } # should exist

      it 'returns a decorated collection' do
        is_expected.to match_array persisted
        is_expected.to be_all &:decorated?
      end

      it 'uses cached records' do
        expect(associated).not_to be_loaded

        associated.load

        expect { subject.to_a }.to execute.exactly(0).queries
      end

      it 'caches records' do
        expect(associated).not_to be_loaded

        associated.decorate

        expect { subject.to_a; associated.load }.to execute.exactly(0).queries
      end

      context 'with unsaved records' do
        before { unsaved } # should exist

        it 'respects unsaved records' do
          is_expected.to match_array persisted + unsaved
        end
      end
    end
  end
end
