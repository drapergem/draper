require 'spec_helper'
require 'support/dummy_app'
require 'support/matchers/have_text'
SimpleCov.command_name 'test:integration'

app = DummyApp.new(ENV["RAILS_ENV"])
spec_types = {
  view: ["/posts/1", "PostsController"],
  mailer: ["/posts/1/mail", "PostMailer"]
}

app.start_server do
  spec_types.each do |type, (path, controller)|
    page = app.get(path)

    describe "in a #{type}" do
      it "runs in the correct environment" do
        expect(page).to have_text(app.environment).in("#environment")
      end

      it "uses the correct view context controller" do
        expect(page).to have_text(controller).in("#controller")
      end

      it "can use built-in helpers" do
        expect(page).to have_text("Once upon a...").in("#truncated")
      end

      it "can use built-in private helpers" do
        # Nokogiri unescapes text!
        expect(page).to have_text("<script>danger</script>").in("#html_escaped")
      end

      it "can use user-defined helpers from app/helpers" do
        expect(page).to have_text("Hello, world!").in("#hello_world")
      end

      it "can use user-defined helpers from the controller" do
        expect(page).to have_text("Goodnight, moon!").in("#goodnight_moon")
      end

      # _path helpers aren't available in mailers
      if type == :view
        it "can be passed to path helpers" do
          expect(page).to have_text("/en/posts/1").in("#path_with_decorator")
        end

        it "can use path helpers with a model" do
          expect(page).to have_text("/en/posts/1").in("#path_with_model")
        end

        it "can use path helpers with an id" do
          expect(page).to have_text("/en/posts/1").in("#path_with_id")
        end
      end

      it "can be passed to url helpers" do
        expect(page).to have_text("http://www.example.com:12345/en/posts/1").in("#url_with_decorator")
      end

      it "can use url helpers with a model" do
        expect(page).to have_text("http://www.example.com:12345/en/posts/1").in("#url_with_model")
      end

      it "can use url helpers with an id" do
        expect(page).to have_text("http://www.example.com:12345/en/posts/1").in("#url_with_id")
      end
    end
  end
end
