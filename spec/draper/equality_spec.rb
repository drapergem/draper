require 'spec_helper'
require 'support/shared_examples/equality'

module Draper
  describe Equality do
    describe "#==" do
      it_behaves_like "decoration-aware #==", Object.new.extend(Equality)
    end
  end
end
