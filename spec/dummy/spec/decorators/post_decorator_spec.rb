require 'spec_helper'

describe PostDecorator do
  subject { PostDecorator.new(source) }
  let(:source) { Post.create }

  it "can use path helpers with its model" do
    subject.path_with_model.should == "/en/posts/#{source.id}"
  end

  it "can use path helpers with its id" do
    subject.path_with_id.should == "/en/posts/#{source.id}"
  end

  it "can use url helpers with its model" do
    subject.url_with_model.should == "http://www.example.com:12345/en/posts/#{source.id}"
  end

  it "can use url helpers with its id" do
    subject.url_with_id.should == "http://www.example.com:12345/en/posts/#{source.id}"
  end

  it "can be passed implicitly to url_for" do
    subject.link.should == "<a href=\"/en/posts/#{source.id}\">#{source.id}</a>"
  end

  it "serializes overriden attributes" do
    subject.serializable_hash["updated_at"].should be :overridden
  end
end
