require 'spec_helper'
require 'support/dummy_app'

shared_examples_for "a decorator in a view" do
  it "works" do
    # it runs in the correct environment
    page.should have_css "#environment", text: environment

    # it can use path helpers with a model
    page.should have_css "#path_with_model", text: "/en/posts/1"

    # it can use path helpers with an id
    page.should have_css "#path_with_id", text: "/en/posts/1"

    # it can use url helpers with a model
    page.should have_css "#url_with_model", text: "http://www.example.com/en/posts/1"

    # it can use url helpers with an id
    page.should have_css "#url_with_id", text: "http://www.example.com/en/posts/1"
  end
end

describe "integration" do
  include Capybara::DSL

  rails_env = ENV["RAILS_ENV"].to_s
  raise ArgumentError, "RAILS_ENV must be development or production" unless ["development", "production"].include?(rails_env)

  app = DummyApp.new(rails_env)

  app.start_server do
    describe "in #{rails_env}" do
      let(:environment) { rails_env }
      before { Capybara.app_host = app.url }

      context "in a view" do
        before { visit("/posts/1") }

        it_behaves_like "a decorator in a view"
      end

      context "in a mailer" do
        before { visit("/posts/1/mail") }

        it_behaves_like "a decorator in a view"
      end
    end
  end

end
