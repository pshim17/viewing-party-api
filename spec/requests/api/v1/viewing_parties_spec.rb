require 'rails_helper'

RSpec.describe "Api::V1::ViewingParties", type: :request do
  describe "Get Top Rated Movies" do
    context "request is valid" do
      it "returns 201 OK" do
        VCR.use_cassette("top_rated_movies") do
          get api_v1_movies_path

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body, symbolize_names: true)

          expect(json[:data]).to be_an(Array)
          expect(json[:data].first[:type]).to eq("movie")
          expect(json[:data].first[:id]).to be_present
          expect(json[:data].first[:attributes][:title]).to eq("The Shawshank Redemption")
          expect(json[:data].first[:attributes][:vote_average]).to eq(8.7)
        end
      end
    end
  end

  describe "Get Movie Search Endpoint" do
    context "request is valid" do
      it "returns 200 OK and provides expected fields" do
        VCR.use_cassette("search_movies") do
          get "/api/v1/movies/search", params: { query: "Lord of the Rings" }

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body, symbolize_names: true)

          expect(json[:data]).to be_an(Array)
          expect(json[:data].first[:type]).to eq("movie")
          expect(json[:data].first[:id]).to be_present
          expect(json[:data].first[:attributes][:title]).to eq("The Lord of the Rings: The War of the Rohirrim")
          expect(json[:data].first[:attributes][:vote_average]).to eq(6.7)

          expect(json[:data]).to be_an(Array)
          expect(json[:data].last[:type]).to eq("movie")
          expect(json[:data].last[:id]).to be_present
          expect(json[:data].last[:attributes][:title]).to eq("The Making of The Fellowship of the Ring")
          expect(json[:data].last[:attributes][:vote_average]).to eq(8.9)
        end
      end
    end
  end
end
