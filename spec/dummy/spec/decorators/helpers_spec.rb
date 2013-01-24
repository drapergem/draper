require 'spec_helper'

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

  it "gets the same helper object as a decorator" do
    decorator = Draper::Decorator.new(Object.new)

    expect(helpers).to be decorator.helpers
  end
end
