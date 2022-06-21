require 'rails_helper'
RSpec.describe 'Users', type: :request do
  describe 'Get/index: Successful Reponse' do
    before do
      FactoryBot.create_list(:user, 10)
      get '/v1/user'
    end
    it 'return status code 200' do
      expect(response).to have_http_status(:success)
    end
    it 'returns all users' do
      expect(json['data'].size).to eq(10)
    end
  end
  describe 'Post/Create: Create user successfully' do
    let!(:new_user) { FactoryBot.create(:user) }
    before do
      get '/v1/user'
      current_user = json['data'].select do |us|
        us['username'] == new_user.username && us['password'] == new_user.password
      end
      delete "/v1/user/#{current_user[0]['id']}" unless current_user.empty?
      post '/v1/user', params:
                            {
                              user: {
                                Full_name: new_user.Full_name,
                                username: new_user.username,
                                password: new_user.password,
                                role: new_user.role
                              }
                            }
    end
    it 'return status 200' do
      expect(response).to have_http_status(:success)
    end
    it 'Raise exception for duplicated users' do
      post '/v1/user'
      expect(response).to have_http_status(422)
    end
  end
  describe 'Post/create: Create user with Wrong parametrs' do
    let!(:new_user) { FactoryBot.create(:user) }
    it 'empty body parametrs' do
      post '/v1/user'
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it 'missing body parametrs' do
      post '/v1/user', params:
                               {
                                 user: {
                                   Full_name: new_user.Full_name,
                                   username: new_user.username,
                                   password: new_user.password
                                 }
                               }
      expect(response).to have_http_status(:bad_request)
    end
  end
  describe 'Patch/update' do
    let!(:new_user) { FactoryBot.create(:user) }
    it 'update with not found user id' do
      patch '/v1/user/1025', params:
                               {
                                 user: {
                                   username: 'Lilly'
                                 }
                               }
      expect(response).to have_http_status(404)
    end
    it 'update with wrong parametr' do
      get '/v1/user'
      current_user = json['data'].select do |us|
      us['username'] == new_user.username && us['password'] == new_user.password
      end
      id = current_user[0]['id'] 
      patch "/v1/user/#{id}", params:
                           {
                             user: {
                               phone: 77_471_580
                             }
                           }
      expect(response).to have_http_status(401)
    end
    it 'update not exist user with correct parametrs' do
      patch '/v1/user/1', params:
                          {
                            user: {
                              username: 'zizou'
                            }
                          }
      expect(response).to have_http_status(404)
    end
  end
  describe 'Delete/Destroy' do
    it 'delete not existed user' do
      delete '/v1/user/1189'
      expect(response).to have_http_status(422)
    end
    it 'delete successfully exist user' do
      delete '/v1/user/1'
    end
  end
end
