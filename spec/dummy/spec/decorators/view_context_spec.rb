require_relative '../rails_helper'

def it_does_not_leak_view_context
  2.times do
    it "has an independent view context" do
      expect(Draper::ViewContext.current).not_to be :leaked
      Draper::ViewContext.current = :leaked
    end
  end
end

RSpec.describe "A decorator spec", type: :decorator do
  it_does_not_leak_view_context
end

RSpec.describe "A controller spec", type: :controller do
  it_does_not_leak_view_context
end

RSpec.describe "A mailer spec", type: :mailer do
  it_does_not_leak_view_context
end
