describe "A spec in this folder" do
  it "is a decorator spec" do
    expect(example.metadata[:type]).to be :decorator
  end
end

describe "A decorator spec" do
  it "can access helpers through `helper`" do
    expect(helper.content_tag(:p, "Help!")).to eq "<p>Help!</p>"
  end

  it "can access helpers through `helpers`" do
    expect(helpers.content_tag(:p, "Help!")).to eq "<p>Help!</p>"
  end

  it "can access helpers through `h`" do
    expect(h.content_tag(:p, "Help!")).to eq "<p>Help!</p>"
  end
end
