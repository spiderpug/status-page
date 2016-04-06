require 'spec_helper'

describe StatusPage::Providers::Cache do
  subject { described_class.new(request: ActionController::TestRequest.create) }

  describe '#provider_name' do
    it { expect(described_class.provider_name).to eq('cache') }
  end

  describe '#check!' do
    it 'succesfully checks' do
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'failing' do
      before do
        Providers.stub_cache_failure
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(StatusPage::Providers::CacheException)
      end
    end
  end

  describe '#configurable?' do
    it { expect(described_class).not_to be_configurable }
  end

  describe '#key' do
    it { expect(subject.send(:key)).to eq('status-cache:0.0.0.0') }
  end
end
