# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubscribersController, type: :controller do
  describe "GET /subscribers" do
    it "returns 200 and a list of subscribers and pagination object" do
      get :index, params: {}, format: :json

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/json; charset=utf-8")

      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:subscribers]).not_to be_nil
      expect(json[:pagination]).not_to be_nil
      expect(json[:subscribers].count).to eq(100)
    end

    it "sets the records per page" do
      get :index, params: {per_page: 25}, format: :json

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/json; charset=utf-8")

      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:subscribers]).not_to be_nil
      expect(json[:pagination]).not_to be_nil
      expect(json[:subscribers].count).to eq(25)
      expect(json[:pagination][:total_pages]).to eq(6) # ceiling ( 127 seeded records / 25 per pages ) = 6
    end

    it "sets the records per page and the page number" do
      get :index, params: {per_page: 20, page: 7}, format: :json

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/json; charset=utf-8")

      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:subscribers]).not_to be_nil
      expect(json[:pagination]).not_to be_nil
      expect(json[:pagination][:total_pages]).to eq(7) # ceiling ( 127 seeded records / 20 per pages ) = 7
      expect(json[:subscribers].count).to eq(7) # 7th page has the final 7 records
    end
  end

  describe "POST /subscribers" do
    it "returns 201 if it successfully creates a subscriber" do
      post :create, params: {email: "test@test.com", name: "John Smith"}, format: :json

      expect(response).to have_http_status(:created)
      expect(response.content_type).to eq("application/json; charset=utf-8")

      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:message]).to eq "Subscriber created successfully"
    end

    describe "returns 403 if field validation fails" do
      it "does not have a name" do
        post :create, params: {email: "test@test.com"}, format: :json

        expect(response).to have_http_status(:forbidden)
        expect(response.content_type).to eq("application/json; charset=utf-8")

        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:message]).to match "Subscriber not created"
        expect(json[:message]).to match "Name can't be blank"
      end

      it "does not have an email" do
        post :create, params: {name: "John Smith"}, format: :json

        expect(response).to have_http_status(:forbidden)
        expect(response.content_type).to eq("application/json; charset=utf-8")

        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:message]).to match "Subscriber not created"
        expect(json[:message]).to match "Email can't be blank"
      end

      it "does not have a valid email" do
        post :create, params: {email: "notavalidemail", name: "John Smith"}, format: :json

        expect(response).to have_http_status(:forbidden)
        expect(response.content_type).to eq("application/json; charset=utf-8")

        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:message]).to match "Subscriber not created"
        expect(json[:message]).to match "Email is invalid"
      end

      it "has a duplicate email" do
        subscriber = Subscriber.new(name: "Test Guy", email: "test@test.com", status: "active")
        subscriber.save!

        post :create, params: {email: "test@test.com", name: "John Smith"}, format: :json

        expect(response).to have_http_status(:forbidden)
        expect(response.content_type).to eq("application/json; charset=utf-8")

        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:message]).to match "Subscriber not created"
        expect(json[:message]).to match "Email has already been taken"
      end

      it "has a duplicate email, case insensitive" do
        subscriber = Subscriber.new(name: "Test Guy", email: "test@test.com", status: "active")
        subscriber.save!

        post :create, params: {email: "Test@Test.com", name: "John Smith"}, format: :json

        expect(response).to have_http_status(:forbidden)
        expect(response.content_type).to eq("application/json; charset=utf-8")

        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:message]).to match "Subscriber not created"
        expect(json[:message]).to match "Email has already been taken"
      end
    end
  end

  describe "PATCH /subscribers/:id" do
    it "returns 200 if it successfully updates a subscriber" do
      subscriber = Subscriber.new(name: "Test Guy", email: "tguy@mail.com", status: "active")
      subscriber.save!

      patch :update, params: {id: subscriber.id, status: "inactive"}, format: :json

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/json; charset=utf-8")

      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:message]).to eq "Subscriber updated successfully"
      expect(subscriber.reload.status).to eq ("inactive")
    end

    it "returns 404 if it cannot find the subscriber" do
      patch :update, params: {id: 999, status: "inactive"}, format: :json

      expect(response).to have_http_status(:not_found)

      expect(response.content_type).to eq("application/json; charset=utf-8")

      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:message]).to match("Subscriber not updated successfully")
    end
  end
end
