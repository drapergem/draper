require 'spec_helper'
require 'active_record'

module Draper
  module QueryMethods
    describe LoadStrategy do
      describe '#new' do
        subject { described_class.new(:active_record) }

        it { is_expected.to be_an_instance_of(LoadStrategy::ActiveRecord) }
      end
    end

    describe LoadStrategy::ActiveRecord do
      describe '#allowed?' do
        it 'checks whether or not ActiveRecord::Relation::VALUE_METHODS has the given method' do
          allow(::ActiveRecord::Relation::VALUE_METHODS).to receive(:include?)

          described_class.new.allowed? :foo

          expect(::ActiveRecord::Relation::VALUE_METHODS).to have_received(:include?).with(:foo)
        end
      end
    end
  end
end
