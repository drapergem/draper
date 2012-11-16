require 'spec_helper'
require 'support/dummy_app'
require 'support/matchers/have_text'

app = DummyApp.new(ENV["RAILS_ENV"])

app.start_server do
  {view: "/posts/1", mailer: "/posts/1/mail"}.each do |type, path|
    page = app.get(path)

    describe "in a #{type}" do
      it "runs in the correct environment" do
        page.should have_text(app.environment).in("#environment")
      end

      it "can use path helpers with a model" do
        page.should have_text("/en/posts/1").in("#path_with_model")
      end

      it "can use path helpers with an id" do
        page.should have_text("/en/posts/1").in("#path_with_id")
      end

      it "can use url helpers with a model" do
        page.should have_text("http://www.example.com/en/posts/1").in("#url_with_model")
      end

      it "can use url helpers with an id" do
        page.should have_text("http://www.example.com/en/posts/1").in("#url_with_id")
      end
    end
  end
end
