require 'spec_helper'

describe Draper, '.undecorate' do
  it 'undecorates a decorated object' do
    object = Model.new
    decorator = Draper::Decorator.new(object)
    expect(Draper.undecorate(decorator)).to equal object
  end

  it 'passes a non-decorated object through' do
    object = Model.new
    expect(Draper.undecorate(object)).to equal object
  end

  it 'passes a non-decorator object through' do
    object = Object.new
    expect(Draper.undecorate(object)).to equal object
  end
end
