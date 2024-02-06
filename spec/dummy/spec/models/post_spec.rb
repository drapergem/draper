require 'spec_helper'
require 'shared_examples/decoratable'

RSpec.describe Post do
  it_behaves_like 'a decoratable model'

  it { should be_a ApplicationRecord }
end
