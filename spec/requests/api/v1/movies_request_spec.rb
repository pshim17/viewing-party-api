require 'rails_helper'

RSpec.describe "Movies API", type: :request do
  describe "GET /api/v1/movies" do
    it "returns a successful response" do
      VCR.use_cassette("top_rated_movies") do
        get "/api/v1/movies"
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)["data"].count).to eq(20)
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

    describe "Get Movie Details Endpoint" do
      context "request is valid" do
        it "returns 200 OK and provides expected fields" do
          VCR.use_cassette("details_movies") do
            get "/api/v1/movies/details", params: { movie_id: 218 }
  
            expect(response).to have_http_status(:ok)
            json = JSON.parse(response.body, symbolize_names: true)
  
            expect(json[:data]).to be_an(Hash)
            expect(json[:data][:type]).to eq("movie")
            expect(json[:data][:id]).to eq(218)
            expect(json[:data][:attributes][:title]).to eq("The Terminator")
            expect(json[:data][:attributes][:vote_average]).to eq(7.662)
            expect(json[:data][:attributes][:runtime]).to eq("1 hour(s), 48 minutes")
            expect(json[:data][:attributes][:genres]).to eq(["Action", "Thriller", "Science Fiction"])
            expect(json[:data][:attributes][:summary]).to eq("In the post-apocalyptic future, reigning tyrannical supercomputers teleport a cyborg assassin known as the \"Terminator\" back to 1984 to kill Sarah Connor, whose unborn son is destined to lead insurgents against 21st century mechanical hegemony. Meanwhile, the human-resistance movement dispatches a lone warrior to safeguard Sarah. Can he stop the virtually indestructible killing machine?")
            expect(json[:data][:attributes][:cast].length).to eq(10)
            expect(json[:data][:attributes][:total_reviews]).to eq(8)
            expect(json[:data][:attributes][:reviews].count).to eq(5)
          end
        end
      end
    end
  end
end