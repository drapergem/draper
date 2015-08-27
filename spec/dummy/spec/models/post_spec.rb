require_relative '../spec_helper'
require_relative '../shared_examples/decoratable'

RSpec.describe Post do
  it_behaves_like "a decoratable model"
end
