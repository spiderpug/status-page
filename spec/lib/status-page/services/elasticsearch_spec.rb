require 'spec_helper'

describe StatusPage::Services::Elasticsearch do
  subject { described_class.new(request: ActionController::TestRequest.create) }

  describe '#service_name' do
    it { expect(described_class.service_name).to eq('Elasticsearch') }
  end

  describe '#check!' do
    it 'succesfully checks' do
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'failing' do
      before do
        Services.stub_elasticsearch_failure
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(StatusPage::Services::ElasticsearchException)
      end
    end
  end

  describe '#configurable?' do
    it { expect(described_class).to be_configurable }
  end
end
