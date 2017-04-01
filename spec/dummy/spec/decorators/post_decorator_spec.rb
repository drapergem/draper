require 'spec_helper'

describe PostDecorator do
  let(:decorator) { PostDecorator.new(object) }
  let(:object) { Post.create }

  it "can use built-in helpers" do
    expect(decorator.truncated).to eq "Once upon a..."
  end

  it "can use built-in private helpers" do
    expect(decorator.html_escaped).to eq "&lt;script&gt;danger&lt;/script&gt;"
  end

  it "can use user-defined helpers from app/helpers" do
    expect(decorator.hello_world).to eq "Hello, world!"
  end

  it "can be passed to path helpers" do
    expect(helpers.post_path(decorator)).to eq "/en/posts/#{object.id}"
  end

  it "can use path helpers with its model" do
    expect(decorator.path_with_model).to eq "/en/posts/#{object.id}"
  end

  it "can use path helpers with its id" do
    expect(decorator.path_with_id).to eq "/en/posts/#{object.id}"
  end

  it "can be passed to url helpers" do
    expect(helpers.post_url(decorator)).to eq "http://www.example.com:12345/en/posts/#{object.id}"
  end

  it "can use url helpers with its model" do
    expect(decorator.url_with_model).to eq "http://www.example.com:12345/en/posts/#{object.id}"
  end

  it "can use url helpers with its id" do
    expect(decorator.url_with_id).to eq "http://www.example.com:12345/en/posts/#{object.id}"
  end

  it "can be passed implicitly to url_for" do
    expect(decorator.link).to eq "<a href=\"/en/posts/#{object.id}\">#{object.id}</a>"
  end

  it "serializes overriden attributes" do
    expect(decorator.serializable_hash["updated_at"]).to be :overridden
  end

  it "serializes to JSON" do
    json = decorator.to_json
    expect(json).to match /"updated_at":"overridden"/
  end

  it "serializes to XML" do
    xml = Capybara.string(decorator.to_xml)
    expect(xml).to have_css "post > updated-at", text: "overridden"
  end

  it "uses a test view context from BaseController" do
    expect(Draper::ViewContext.current.controller).to be_an BaseController
  end
end
