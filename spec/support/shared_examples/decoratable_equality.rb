shared_examples_for "decoration-aware #==" do |subject|
  it "is true for itself" do
    expect(subject == subject).to be_truthy
  end

  it "is false for another object" do
    expect(subject == Object.new).to be_falsey
  end

  it "is true for a decorated version of itself" do
    decorated = double(object: subject, decorated?: true)

    expect(subject == decorated).to be_truthy
  end

  it "is false for a decorated other object" do
    decorated = double(object: Object.new, decorated?: true)

    expect(subject == decorated).to be_falsey
  end

  it "is false for a decoratable object with a `object` association" do
    decoratable = double(object: subject, decorated?: false)

    expect(subject == decoratable).to be_falsey
  end

  it "is false for an undecoratable object with a `object` association" do
    undecoratable = double(object: subject)

    expect(subject == undecoratable).to be_falsey
  end

  it "is true for a multiply-decorated version of itself" do
    decorated = double(object: subject, decorated?: true)
    redecorated = double(object: decorated, decorated?: true)

    expect(subject == redecorated).to be_truthy
  end
end
