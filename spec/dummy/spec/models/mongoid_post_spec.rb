require_relative '../spec_helper'
require_relative '../shared_examples/decoratable'

if defined?(Mongoid)
  RSpec.describe MongoidPost do
    it_behaves_like "a decoratable model"
  end
end
