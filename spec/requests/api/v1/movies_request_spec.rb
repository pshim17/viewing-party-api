require 'rails_helper'

RSpec.describe "Movies API", type: :request do
  describe "GET /api/v1/movie" do
    it "returns a successful response" do
      get "/api/v1/movie"
      expect(response).to have_http_status(:success)
    end
  end
end