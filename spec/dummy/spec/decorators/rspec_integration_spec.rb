describe "A spec in this folder" do
  it "is a decorator spec" do
    example.metadata[:type].should be :decorator
  end
end

describe "A decorator spec" do
  it "can access helpers through `helper`" do
    helper.content_tag(:p, "Help!").should == "<p>Help!</p>"
  end

  it "can access helpers through `helpers`" do
    helpers.content_tag(:p, "Help!").should == "<p>Help!</p>"
  end

  it "can access helpers through `h`" do
    h.content_tag(:p, "Help!").should == "<p>Help!</p>"
  end
end
