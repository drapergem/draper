shared_examples_for "a decoratable model" do
  describe ".decorate" do
    it "applies a relation decorator to a scope" do
      described_class.create
      decorated = described_class.limit(1).decorate

      expect(decorated.size).to eq(1)
      expect(decorated).to be_decorated

      expect(decorated.to_a.size).to eq(1)
      expect(decorated.to_a).to be_decorated

      expect(decorated.first).to be_decorated
    end
  end

  describe "#==" do
    it "is true for other instances' decorators" do
      pending "Mongoid < 3.1 overrides `#==`" if defined?(Mongoid) && Mongoid::VERSION.to_f < 3.1 && described_class < Mongoid::Document

      described_class.create
      one = described_class.first
      other = described_class.first

      expect(one).not_to be other
      expect(one == other.decorate).to be_truthy
    end
  end
end
