require 'spec_helper'

describe Draper, '.undecorate_chain' do
  let!(:object) { Model.new }
  let!(:decorated_inner) { Class.new(Draper::Decorator).new(object) }
  let!(:decorated_outer) { Class.new(Draper::Decorator).new(decorated_inner) }

  it 'undecorates full chain of decorated objects' do
    expect(Draper.undecorate_chain(decorated_outer)).to equal object
  end

  it 'passes a non-decorated object through' do
    expect(Draper.undecorate_chain(object)).to equal object
  end

  it 'passes a non-decorator object through' do
    object = Object.new
    expect(Draper.undecorate_chain(object)).to equal object
  end
end
