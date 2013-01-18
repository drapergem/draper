require 'spec_helper'
require 'support/shared_examples/decoratable_equality'

module Draper
  describe Decoratable::Equality do
    describe "#==" do
      it_behaves_like "decoration-aware #==", Object.new.extend(Decoratable::Equality)
    end
  end
end
