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

  describe "Sad paths" do
    context "Missing required fields" do 
      it "returns 422: bad request and error message with missing required fields" do
        post api_v1_viewing_parties_path, params: { name: "Cool ppl only viewing_party", movie_id: 278, movie_title: "The Shawshank Redemption" }

        json = JSON.parse(response.body)

        expect(response).to have_http_status(:bad_request)
        expect(json["message"]).to eq("Missing required field(s): start_time, end_time")
      end
    end 

    context "Party duration is less than movie runtime" do
      it "returns 422: unprocessable_content and an error message" do
        post api_v1_viewing_parties_path, params: {   
          "name": "David's Bday Movie Bash!",
          "start_time": "2025-02-01 14:00:00",
          "end_time": "2025-02-01 14:30:00",
          "movie_id": 278,
          "movie_title": "The Shawshank Redemption",
          "invitees": [3, 2, 1] 
        }
        
        json = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["message"]).to eq("Party duration cannot be less than movie runtime")
      end
    end
  end
end
