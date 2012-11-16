require 'spec_helper'
require 'support/dummy_app'
require 'support/matchers/have_text'

shared_examples_for "a decorator in a view" do
  it "works" do
    # it runs in the correct environment
    page.should have_text(environment).in("#environment")

    # it can use path helpers with a model
    page.should have_text("/en/posts/1").in("#path_with_model")

    # it can use path helpers with an id
    page.should have_text("/en/posts/1").in("#path_with_id")

    # it can use url helpers with a model
    page.should have_text("http://www.example.com/en/posts/1").in("#url_with_model")

    # it can use url helpers with an id
    page.should have_text("http://www.example.com/en/posts/1").in("#url_with_id")
  end
end

describe "integration" do
  app = DummyApp.new(ENV["RAILS_ENV"])

  app.start_server do
    describe "in #{app.environment}" do
      let(:environment) { app.environment }

      context "in a view" do
        let(:page) { app.get("/posts/1") }

        it_behaves_like "a decorator in a view"
      end

      context "in a mailer" do
        let(:page) { app.get("/posts/1/mail") }

        it_behaves_like "a decorator in a view"
      end
    end
  end

end
