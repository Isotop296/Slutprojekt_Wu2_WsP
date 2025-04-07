require 'sinatra'
require 'json'
require 'sinatra/cross_origin'
require 'bcrypt'
require 'sqlite3'
require 'jwt'

#hdgfhgghf
class App < Sinatra::Base

    SECRET_KEY = "ArmanÄrteror"

    def db
        return @db if @db

        @db = SQLite3::Database.new("db/spel.sqlite")
        @db.results_as_hash = true
        return @db
    end

    configure do
        enable :cross_origin
    end

    options '*' do
        response.headers["Access-Control-Allow-Origin"] = "*"
        response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
        response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
        status 200
      end
      
      

      before do
        response.headers["Access-Control-Allow-Origin"] = "*"
        response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
        response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
    end
    

    enable :sessions



    post '/api/login' do
        begin
          request_data = JSON.parse(request.body.read)
          email = request_data["email"]
          password = request_data["password"]
      
          user = db.execute('SELECT * FROM users WHERE email = ?', [email]).first
      
          if user && BCrypt::Password.new(user["password"]) == password
            payload = {
              user_id: user["id"],
              role: user["role"],
              exp: Time.now.to_i + 3600
            }
            token = JWT.encode(payload, SECRET_KEY, 'HS256')
      
            status 200
            content_type :json
            { message: "Login successful", token: token }.to_json
          else
            status 401
            content_type :json
            { message: "Invalid email or password" }.to_json
          end
        rescue => e
          status 500
          content_type :json
          { message: "Server error", error: e.message }.to_json
        end
    end




end


