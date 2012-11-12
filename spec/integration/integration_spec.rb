require 'spec_helper'
require 'support/dummy_app'

describe "integration" do
  include Capybara::DSL

  environment = ENV["RAILS_ENV"].to_s
  raise ArgumentError, "RAILS_ENV must be development or production" unless ["development", "production"].include?(environment)

  app = DummyApp.new(environment)

  app.start_server do
    describe "in #{environment}" do
      before { Capybara.app_host = app.url }

      it "runs in the correct environment" do
        visit("/posts/1")
        page.should have_css "#environment", text: environment
      end

      it "decorates" do
        visit("/posts/1")
        page.should have_content "Today"
      end

      it "can use path helpers with a model" do
        visit("/posts/1")
        page.should have_css "#path_with_model", text: "/en/posts/1"
      end

      it "can use path helpers with an id" do
        visit("/posts/1")
        page.should have_css "#path_with_id", text: "/en/posts/1"
      end

      it "can use url helpers with a model" do
        visit("/posts/1")
        page.should have_css "#url_with_model", text: "http://www.example.com/en/posts/1"
      end

      it "can use url helpers with an id" do
        visit("/posts/1")
        page.should have_css "#url_with_id", text: "http://www.example.com/en/posts/1"
      end

    end
  end

end
