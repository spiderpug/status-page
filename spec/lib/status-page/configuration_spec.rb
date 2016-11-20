require 'spec_helper'

describe StatusPage::Configuration do
  describe 'defaults' do
    it { expect(subject.providers).to eq([]) }
    it { expect(subject.error_callback).to be_nil }
    it { expect(subject.basic_auth_credentials).to be_nil }
  end

  describe 'providers' do
    [:cache, :database, :redis, :resque, :sidekiq].each do |service_name|
      before do
        subject.instance_variable_set('@providers', [])

        stub_const("StatusPage::Services::#{service_name.capitalize}", Class.new do
          def initialize(*args)
          end
        end)
      end

      it "configures #{service_name}" do
        expect {
          subject.use(service_name)
        }.to change { subject.providers }.to(["StatusPage::Services::#{service_name.capitalize}".constantize])
      end
    end
  end

  describe 'use with opts' do
    it 'should use redis with opts' do
      monitor = subject.use(:redis, url: 'redis://asdgas:3380')
      expect(monitor.config.url).to eq 'redis://asdgas:3380'
    end
  end

  describe '#add_custom_service' do
    before do
      subject.instance_variable_set('@providers', Set.new)
    end

    context 'inherits' do
      class CustomProvider < StatusPage::Services::Base
      end

      it 'accepts' do
        expect {
          subject.add_custom_service(CustomProvider)
        }.to change { subject.providers }.to([CustomProvider])
      end

      it 'returns CustomProvider class' do
        expect(subject.add_custom_service(CustomProvider)).to be_instance_of(CustomProvider)
      end
    end

    context 'does not inherit' do
      class TestClass
      end

      it 'does not accept' do
        expect {
          subject.add_custom_service(TestClass)
        }.to raise_error(ArgumentError)
      end
    end
  end
end
