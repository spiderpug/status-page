require 'spec_helper'

describe StatusPage::Providers::Resque do
  subject { described_class.new(request: ActionController::TestRequest.create) }

  describe '#provider_name' do
    it { expect(described_class.provider_name).to eq('resque') }
  end

  describe '#check!' do
    it 'succesfully checks' do
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'failing' do
      before do
        Providers.stub_resque_failure
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(StatusPage::Providers::ResqueException)
      end
    end
  end

  describe '#configurable?' do
    it { expect(described_class).not_to be_configurable }
  end
end
