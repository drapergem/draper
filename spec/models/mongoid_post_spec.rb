require 'spec_helper'
require 'shared_examples/decoratable'

if defined?(Mongoid)
  describe MongoidPost do
    it_behaves_like "a decoratable model"
  end
end
