require 'sinatra'
require 'json'
require 'sinatra/cross_origin'
require 'bcrypt'
require 'sqlite3'
require 'jwt'
require 'dotenv/load'


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


    post '/api/create_account' do
        begin 

            request_data = JSON.parse(request.body.read)

            email = request_data["email"]
            password = request_data["password"]
            username = request_data["username"]
            country = request_data["country"]
        
            existing_user = db.execute('SELECT * FROM users WHERE email = ?', [email]).first

        
            if existing_user
              status 409  
              content_type :json
              return { message: "User already exists" }.to_json
            end
           password_digest = BCrypt::Password.create(password)

           p password_digest


            db.execute('INSERT INTO users (email, password, username, country) 
                VALUES (?, ?, ?, ?)',[email, password_digest, username, country])

            new_user = db.execute('SELECT * FROM users WHERE email = ?', [email]).first

            payload = {
                user_id: new_user["id"],
                role: new_user["role"],
                exp: Time.now.to_i + 3600
            }

            token = JWT.encode(payload, SECRET_KEY, 'HS256')
            status 200
            content_type :json
            { message: "Account created successfully", token: token }.to_json

            rescue => e
                status 500
                content_type :json
                { message: "Server error", error: e.message }.to_json
            end
        end

        get "/api/GetGameByGenre" do
            genre = params[:genre]
            rawg_url = "https://api.rawg.io/api/games/#{id}?key=#{ENV['RAWG_KEY']}"
            response = HTTParty.get(rawg_url)
            json response.body
          end


end


