require 'spec_helper'

describe ApplicationRecord do
  it { expect(described_class.superclass).to eq ActiveRecord::Base }

  it { expect(described_class.abstract_class).to be_truthy }
end
