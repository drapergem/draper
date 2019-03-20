require 'spec_helper'

module Draper
  RSpec.describe Configuration do
    it 'yields Draper on configure' do
      Draper.configure { |config| expect(config).to be Draper }
    end

    describe '#default_controller' do
      it 'defaults default_controller to ApplicationController' do
        expect(Draper.default_controller).to be ApplicationController
      end

      it 'allows customizing default_controller through configure' do
        default = Draper.default_controller

        Draper.configure do |config|
          config.default_controller = CustomController
        end

        expect(Draper.default_controller).to be CustomController

        Draper.default_controller = default
      end
    end

    describe '#default_query_methods_strategy' do
      let!(:default) { Draper.default_query_methods_strategy }

      subject { Draper.default_query_methods_strategy }

      context 'when there is no custom strategy' do
        it { is_expected.to eq(:active_record) }
      end

      context 'when using a custom strategy' do
        before do
          Draper.configure do |config|
            config.default_query_methods_strategy = :mongoid
          end
        end

        after { Draper.default_query_methods_strategy = default }

        it { is_expected.to eq(:mongoid) }
      end
    end
  end
end
