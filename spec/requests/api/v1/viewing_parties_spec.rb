require 'rails_helper'

RSpec.describe "Api::V1::ViewingParties", type: :request do
  before(:each) do 
    @user1 = create(:user, id: 1)
    @user2 = create(:user, id: 2)
    @user3 = create(:user, id: 3)
  end

  describe "Happy paths" do
    context "Can retrieve 20 top rated movies" do
      it "returns 201 OK" do
        VCR.use_cassette("top_rated_movies") do
          get api_v1_movies_path
          json = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(:ok)
          expect(json[:data]).to be_an(Array)
          expect(json[:data].count).to be(20)
          expect(json[:data].first[:type]).to eq("movie")
          expect(json[:data].first[:id]).to be_present
          expect(json[:data].first[:attributes][:title]).to eq("The Shawshank Redemption")
          expect(json[:data].first[:attributes][:vote_average]).to eq(8.7)
        end
      end
    end

    context "Can create a viewing party" do
      it "returns 201: created" do
        post api_v1_viewing_parties_path, params: {   
          "name": "David's Bday Movie Bash!",
          "start_time": "2025-02-01 11:00:00",
          "end_time": "2025-02-01 14:30:00",
          "movie_id": 278,
          "movie_title": "The Shawshank Redemption",
          "invitees": [ 1, 2, 3 ] 
        }
        
        json = JSON.parse(response.body)
        expect(response).to have_http_status(:created)
        expect(json["data"]["attributes"]["invitees"].count).to eq(3)
      end
    end

    context "Can add a new user to an existing viewing party" do
      it "returns 201 Created and adds the new invitee" do
        post api_v1_viewing_parties_path, params: {   
          "name": "David's Bday Movie Bash!",
          "start_time": "2025-02-01 11:00:00",
          "end_time": "2025-02-01 14:30:00",
          "movie_id": 278,
          "movie_title": "The Shawshank Redemption",
          "invitees": [ 1, 2 ] 
        }

        json = JSON.parse(response.body, symbolize_names: true)
        viewing_party_id = json[:data][:id].to_i

        expect(json[:data][:attributes][:invitees].count).to eq(2) 

        post api_v1_viewing_party_invitees_path(viewing_party_id: viewing_party_id), params: { invitees_user_id: 3 }, as: :json
        re_json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:created)
        expect(re_json[:data][:attributes][:invitees].count).to eq(3) 
        expect(re_json[:data][:attributes][:invitees].last[:id]).to eq(@user3.id)
        expect(re_json[:data][:attributes][:invitees].last[:name]).to eq(@user3.name)
        expect(re_json[:data][:attributes][:invitees].last[:username]).to eq(@user3.username)
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
          "invitees": [ 3, 2, 1 ] 
        }
        json = JSON.parse(response.body)
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["message"]).to eq("Party duration cannot be less than movie runtime")
      end
    end

    context "Party end time is before than start time" do
      it "returns 422: unprocessable_content and an error message" do
        post api_v1_viewing_parties_path, params: {   
          "name": "David's Bday Movie Bash!",
          "start_time": "2025-02-01 14:00:00",
          "end_time": "2025-02-01 13:30:00",
          "movie_id": 278,
          "movie_title": "The Shawshank Redemption",
          "invitees": [ 3, 2, 1 ] 
        }
        json = JSON.parse(response.body)
        
        expect(response).to have_http_status(:bad_request)
        expect(json["message"]).to eq("Party end time cannot be before the start time")
      end
    end

    context "The new invitee user id is invalid" do
      it "returns 422: unprocessable_content and an error message" do
        post api_v1_viewing_parties_path, params: {   
          "name": "David's Bday Movie Bash!",
          "start_time": "2025-02-01 13:00:00",
          "end_time": "2025-02-01 16:00:00",
          "movie_id": 278,
          "movie_title": "The Shawshank Redemption",
          "invitees": [ 1, 2, 777777 ] 
        }
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(json["data"]["attributes"]["invitees"].count).to eq(2) 
        expect(json["data"]["attributes"]["invitees"][0]["id"]).to eq(@user1.id)
        expect(json["data"]["attributes"]["invitees"][0]["name"]).to eq(@user1.name)
        expect(json["data"]["attributes"]["invitees"][0]["username"]).to eq(@user1.username)
        expect(json["data"]["attributes"]["invitees"][1]["id"]).to eq(@user2.id)
        expect(json["data"]["attributes"]["invitees"][1]["name"]).to eq(@user2.name)
        expect(json["data"]["attributes"]["invitees"][1]["username"]).to eq(@user2.username)
      end
    end

    context "Invalid viewing party id" do
      it "returns 404 error" do
        post api_v1_viewing_parties_path, params: {   
          "name": "David's Bday Movie Bash!",
          "start_time": "2025-02-01 11:00:00",
          "end_time": "2025-02-01 14:30:00",
          "movie_id": 278,
          "movie_title": "The Shawshank Redemption",
          "invitees": [ 1, 2 ] 
        }
        json = JSON.parse(response.body, symbolize_names: true)
        viewing_party_id = 77777

        expect(json[:data][:attributes][:invitees].count).to eq(2) 

        post api_v1_viewing_party_invitees_path(viewing_party_id: viewing_party_id), params: { invitees_user_id: 3 }, as: :json
        re_json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "Invalid user id" do
      it "returns 404 error" do
        post api_v1_viewing_parties_path, params: {   
          "name": "David's Bday Movie Bash!",
          "start_time": "2025-02-01 11:00:00",
          "end_time": "2025-02-01 14:30:00",
          "movie_id": 278,
          "movie_title": "The Shawshank Redemption",
          "invitees": [ 1, 2 ] 
        }
        json = JSON.parse(response.body, symbolize_names: true)
        viewing_party_id = json[:data][:id].to_i

        expect(json[:data][:attributes][:invitees].count).to eq(2) 

        post api_v1_viewing_party_invitees_path(viewing_party_id: viewing_party_id), params: { invitees_user_id: 4 }, as: :json
        re_json = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
