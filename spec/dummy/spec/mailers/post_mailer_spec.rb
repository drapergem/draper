require 'spec_helper'

describe PostMailer do
  describe "#decorated_email" do
    subject { Capybara.string(email.body.to_s) }
    let(:email) { PostMailer.decorated_email(post).deliver }
    let(:post) { Post.create }

    it "decorates" do
      subject.should have_content "Today"
    end

    it "can use path helpers with a model" do
      subject.should have_css "#path_with_model", text: "/en/posts/#{post.id}"
    end

    it "can use path helpers with an id" do
      subject.should have_css "#path_with_id", text: "/en/posts/#{post.id}"
    end

    it "can use url helpers with a model" do
      subject.should have_css "#url_with_model", text: "http://www.example.com/en/posts/#{post.id}"
    end

    it "can use url helpers with an id" do
      subject.should have_css "#url_with_id", text: "http://www.example.com/en/posts/#{post.id}"
    end
  end
end
