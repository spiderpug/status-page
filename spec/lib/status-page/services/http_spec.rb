require 'spec_helper'

describe StatusPage::Services::Http do
  subject { described_class.new(request: ActionController::TestRequest.create) }

  describe '#service_name' do
    it { expect(subject.service_name).to eq('Http') }
  end

  before do
    subject.config.url = 'http://localhost:3000'
  end

  describe '#check_response_expectation!' do
    let(:response) { double }
    before do
      allow(response).to receive(:body).and_return('this is the http response')
    end

    it 'Proc should receive response' do
      class ProcWasCallException < StandardError; end
      subject.config.response_expectation = Proc.new{|response| raise ProcWasCallException }

      expect {
        subject.send(:check_response_expectation!, response)
      }.to raise_error(ProcWasCallException)
    end

    context 'String' do
      it 'String included in response' do
        subject.config.response_expectation = 'http response'

        expect {
          subject.send(:check_response_expectation!, response)
        }.not_to raise_error
      end

      it 'String not included in response' do
        subject.config.response_expectation = 'ftp response'

        expect {
          subject.send(:check_response_expectation!, response)
        }.to raise_error(StatusPage::Services::HttpException)
      end
    end

    context 'Regexp' do
      it 'String included in response' do
        subject.config.response_expectation = /http response/

        expect {
          subject.send(:check_response_expectation!, response)
        }.not_to raise_error
      end

      it 'String not included in response' do
        subject.config.response_expectation = /ftp response/

        expect {
          subject.send(:check_response_expectation!, response)
        }.to raise_error(StatusPage::Services::HttpException)
      end
    end

    it 'unknown expectation class' do
      subject.config.response_expectation = Exception

      expect {
        subject.send(:check_response_expectation!, response)
      }.to raise_error(StatusPage::Services::HttpException)
    end
  end

  describe '#check!' do
    let(:response) do
      r = double
      allow(r).to receive(:time).and_return(0.44)
      allow(r).to receive(:connect_time).and_return(0.44)
      allow(r).to receive(:starttransfer_time).and_return(0.44)
      r
    end

    before do
      expect(Typhoeus).to receive(:get).and_return(response)
      subject.config.response_expectation = nil
    end

    it 'succesfully checks pid' do
      expect(response).to receive(:success?).and_return(true)
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'failing' do
      before do
        expect(response).to receive(:success?).and_return(false)
      end

      it 'fails check! on timeout' do
        expect(response).to receive(:timed_out?).and_return(true)
        expect {
          subject.check!
        }.to raise_error(StatusPage::Services::HttpException)
      end

      it 'fails check! on pre-connect error' do
        expect(response).to receive(:timed_out?).and_return(false)
        expect(response).to receive(:code).and_return(0)
        expect(response).to receive(:return_message).and_return("Couldnt resolve host")

        expect {
          subject.check!
        }.to raise_error(StatusPage::Services::HttpException)
      end

      it 'fails check! on internal server error' do
        expect(response).to receive(:timed_out?).and_return(false)
        expect(response).to receive(:code).twice.and_return(500)

        expect {
          subject.check!
        }.to raise_error(StatusPage::Services::HttpException)
      end
    end
  end

  describe '#configurable?' do
    it { expect(described_class).to be_configurable }
  end
end
