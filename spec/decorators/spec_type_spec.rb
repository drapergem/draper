require 'spec_helper'

describe "A spec in this folder" do
  it "is a decorator spec" do
    expect(RSpec.current_example.metadata[:type]).to be :decorator
  end
end
