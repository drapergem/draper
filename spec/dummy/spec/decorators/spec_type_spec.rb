require 'spec_helper'

describe "A spec in this folder" do
  it "is a decorator spec" do
    expect(example.metadata[:type]).to be :decorator
  end
end
