require 'rails_helper'

RSpec.describe Hyrax::UsersController do
  routes { Hyrax::Engine.routes }

  context "If an user has an ORCID id" do
    before(:each) do
      @user = FactoryBot.create(:user, :nims_researcher, orcid: '0000-0002-9986-7223')
    end

    describe "When not logged in" do
      it "should be redirected to SAMURAI" do
        get :show, params: { id: @user.user_identifier }
        expect(response).to redirect_to "https://samurai.nims.go.jp/orcid/#{Hyrax::OrcidValidator.match(@user.orcid)}"
      end
    end

    describe "When logged in" do
      before(:each) do
        sign_in @user
      end

      it "should be redirected to SAMURAI" do
        get :show, params: { id: @user.user_identifier }
        expect(response).to redirect_to "https://samurai.nims.go.jp/orcid/#{Hyrax::OrcidValidator.match(@user.orcid)}"
      end
    end
  end

  context "If an user doesn't have an ORCID id" do
    before(:each) do
      @user = FactoryBot.create(:user, :nims_researcher)
    end

    describe "When not logged in" do
      it "should be redirected to the user page" do
        get :show, params: { id: @user.user_identifier }
        expect(response.status).to eq 404
      end
    end

    describe "When logged in" do
      before(:each) do
        sign_in @user
      end

      it "should be redirected to the user page" do
        get :show, params: { id: @user.user_identifier }
        expect(response.status).to eq 404
      end
    end
  end
end
