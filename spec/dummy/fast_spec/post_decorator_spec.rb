require 'draper'

require 'active_model/naming'
require_relative '../app/decorators/post_decorator'

Draper::ViewContext.test_strategy :fast

Post = Struct.new(:id) { extend ActiveModel::Naming }

describe PostDecorator do
  let(:decorator) { PostDecorator.new(object) }
  let(:object) { Post.new(42) }

  it "can use built-in helpers" do
    expect(decorator.truncated).to eq "Once upon a..."
  end

  it "can use built-in private helpers" do
    expect(decorator.html_escaped).to eq "&lt;script&gt;danger&lt;/script&gt;"
  end

  it "can't use user-defined helpers from app/helpers" do
    expect{decorator.hello_world}.to raise_error NoMethodError, /hello_world/
  end

  it "can't use path helpers" do
    expect{decorator.path_with_model}.to raise_error NoMethodError, /post_path/
  end

  it "can't use url helpers" do
    expect{decorator.url_with_model}.to raise_error NoMethodError, /post_url/
  end

  it "can't be passed implicitly to url_for" do
    expect{decorator.link}.to raise_error ArgumentError
  end
end
