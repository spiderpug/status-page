require 'spec_helper'
require 'timecop'
require './app/controllers/status_page/status_controller'

describe StatusPage::StatusController, :type => :controller do
  routes { StatusPage::Engine.routes }

  let(:time) { Time.local(1990) }

  before do
    providers = []
    providers << StatusPage::Services::Database.new

    allow(StatusPage.config).to receive(:providers).and_return(providers)
    allow(StatusPage.config).to receive(:interval).and_return(0)

    Timecop.freeze(time)
  end

  after do
    Timecop.return
  end

  describe 'basic authentication' do
    let(:username) { 'username' }
    let(:password) { 'password' }

    before do
      that = self
      StatusPage.configure do
        self.basic_auth_credentials = { username: that.username, password: that.password }
      end
    end

    context 'valid credentials provided' do
      before do
        request.env['HTTP_AUTHORIZATION'] =
          ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
      end

      it 'succesfully checks' do
        expect {
          get :index, format: 'json'
        }.not_to raise_error

        expect(response).to be_ok
        json = JSON.parse(response.body)

        expect(json).to have_key('results')
        results = json['results']
        expect(results.first['name']).to eq('Database')
        expect(results.first['status']).to eq('OK')
        expect(results.first['message']).to be_nil
      end
    end

    context 'invalid credentials provided' do
      before do
        request.env['HTTP_AUTHORIZATION'] =
          ActionController::HttpAuthentication::Basic.encode_credentials('', '')
      end

      it 'fails' do
        expect {
          get :index, format: 'json'
        }.not_to raise_error

        expect(response).not_to be_ok
        expect(response.status).to eq(401)
      end
    end
  end

  describe 'GET status.json' do
    before do
      StatusPage.configure do
        self.basic_auth_credentials = nil
      end
    end

    it 'succesfully checks' do
      expect {
        get :index, format: 'json'
      }.not_to raise_error

      expect(response).to be_ok
      json = JSON.parse(response.body)
      expect(json['status']).to eq 'ok'
      expect(json['results'].size).to eq 1
      results = json['results']
      expect(results.first['name']).to eq('Database')
      expect(results.first['status']).to eq('OK')
      expect(results.first['message']).to be_nil
    end

    context 'failing' do
      before do
        Services.stub_database_failure
      end

      it 'should fail' do
        expect {
          get :index, format: 'json'
        }.not_to raise_error

        expect(response).to be_success
        json = JSON.parse(response.body)
        expect(json['status']).to eq 'service_unavailable'
        expect(json['results'].size).to eq 1
        first = json['results'].first
        expect(first['name']).to eq('Database')
        expect(first['status']).to eq('ERROR')
        expect(first['message']).to eq('Exception')
      end
    end
  end
end
