shared_examples_for "decoration-aware #==" do |subject|
  it "is true for itself" do
    expect(subject == subject).to be_true
  end

  it "is false for another object" do
    expect(subject == Object.new).to be_false
  end

  it "is true for a decorated version of itself" do
    decorated = double(source: subject, decorated?: true)

    expect(subject == decorated).to be_true
  end

  it "is false for a decorated other object" do
    decorated = double(source: Object.new, decorated?: true)

    expect(subject == decorated).to be_false
  end

  it "is false for a decoratable object with a `source` association" do
    decoratable = double(source: subject, decorated?: false)

    expect(subject == decoratable).to be_false
  end

  it "is false for an undecoratable object with a `source` association" do
    undecoratable = double(source: subject)

    expect(subject == undecoratable).to be_false
  end

  it "is true for a multiply-decorated version of itself" do
    decorated = double(source: subject, decorated?: true)
    redecorated = double(source: decorated, decorated?: true)

    expect(subject == redecorated).to be_true
  end
end
