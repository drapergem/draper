require 'spec_helper'

describe PostDecorator do
  let(:decorator) { PostDecorator.new(source) }
  let(:source) { Post.create }

  it "can use built-in helpers" do
    expect(decorator.truncated).to eq "Once upon a..."
  end

  it "can use built-in private helpers" do
    expect(decorator.html_escaped).to eq "&lt;script&gt;danger&lt;/script&gt;"
  end

  it "can use user-defined helpers from app/helpers" do
    expect(decorator.hello_world).to eq "Hello, world!"
  end

  it "can use path helpers with its model" do
    expect(decorator.path_with_model).to eq "/en/posts/#{source.id}"
  end

  it "can use path helpers with its id" do
    expect(decorator.path_with_id).to eq "/en/posts/#{source.id}"
  end

  it "can use url helpers with its model" do
    expect(decorator.url_with_model).to eq "http://www.example.com:12345/en/posts/#{source.id}"
  end

  it "can use url helpers with its id" do
    expect(decorator.url_with_id).to eq "http://www.example.com:12345/en/posts/#{source.id}"
  end

  it "can be passed implicitly to url_for" do
    expect(decorator.link).to eq "<a href=\"/en/posts/#{source.id}\">#{source.id}</a>"
  end

  it "serializes overriden attributes" do
    expect(decorator.serializable_hash["updated_at"]).to be :overridden
  end

  it "uses a test view context from ApplicationController" do
    expect(Draper::ViewContext.current.controller).to be_an ApplicationController
  end
end
