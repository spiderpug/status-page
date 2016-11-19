require 'spec_helper'

describe StatusPage::Services::Resque do
  subject { described_class.new(request: ActionController::TestRequest.create) }

  describe '#service_name' do
    it { expect(subject.service_name).to eq('Resque') }
  end

  describe '#check!' do
    it 'succesfully checks' do
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'failing' do
      before do
        Services.stub_resque_failure
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(StatusPage::Services::ResqueException)
      end
    end
  end

  describe '#configurable?' do
    it { expect(described_class).not_to be_configurable }
  end
end
