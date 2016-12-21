require 'rails_helper'
require 'helpers'

RSpec.configure do |c|
  c.include Helpers
end

RSpec.describe Api::DriversController, type: :controller do


  describe "POST #login" do
    it "returns http success" do
      driver_login
      expect(response).to have_http_status(:success)
      expect(response.status).to eq(200)
    end

    it "returns a an error message for non existing email/password combination" do
      post :login, user: { email: "anyemail@email.com", password: "user_password"}
      error_message = { error: 'Invalid Username and/or Password' }
      expect(response.body).to eq(error_message.to_json)
    end

    it "creates a session for the logged in user" do
      driver_login
      expect(session[:current_driver_id]).not_to eq(nil)
    end

    xit "returns a valid user details for valid login" do
      driver_login
      user = User.includes(:driver).find_by(id: session[:current_driver_id])
      returned_user = returned_driver(user)
      expect(response.body).to eq(returned_user.to_json)
    end

  end

  describe "POST #logout" do
    it "returns http success" do
      expect(response).to have_http_status(:success)
      expect(response.status).to eq(200)
    end

    it "logs out the current_driver" do
      expect(session[:current_driver_id]).to eq(nil)
    end
  end

  describe "POST #status" do

    before do
      user = FactoryGirl.create(:user, user_type: "Driver")
      driver = FactoryGirl.create(:driver, user_id: user.id)
      post :status, {user: {"token": user.token}, driver: {"status": 'Active'}}
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
      expect(response.status).to eq(200)
    end

    it "Gives a successfully response for valid driver" do
      response_message = {status: 'success'}
      expect(response.body).to eq response_message.to_json
    end

    it "updates the drivers status to the given status update" do
      user = FactoryGirl.create(:user, user_type: "Driver")
      driver = FactoryGirl.create(:driver, user_id: user.id)
      expect(user.driver.status).to eq Driver::ACTIVE
    end

    it "Sets the response for any status which doesn't conform status constants to Inactive" do
      response_message = {error: 'Unknown status was provided'}
      user = FactoryGirl.create(:user, user_type: "Driver")
      driver = FactoryGirl.create(:driver, user_id: user.id)
      post :status, {user: {"token": user.token}, driver: {"status": "ZZthieyrhs"}}
      expect(response.body).to eq response_message.to_json
    end

    it "Throws an error message for someone who isn't a driver" do
      user = FactoryGirl.create(:user)
      post :status, {user: {"token": user.token}, driver: {"status": "Active"}}
      response_message = {error: 'Details could not be loaded'}
      expect(response.body).to eq response_message.to_json
    end
  end

end
