require 'sinatra'
require 'json'
require 'sinatra/cross_origin'
require 'bcrypt'
require 'sqlite3'
#hdgfhgghf
class App < Sinatra::Base

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
        cross_origin
        
        request_data = JSON.parse(request.body.read)

        email = request_data["email"]
        passwordcr = BCrypt::Password.new(request_data["password"])

        p "hola!"
        user = db.execute('SELECT * FROM users WHERE email = ?', [email]).first

        if user(password) == passwordcr
            status 200
            content_type :json
            { message: "Login successful", token: "fake-jwt-token-123" }.to_json
          else
            status 401
            content_type :json
            { message: "Invalid email or password" }.to_json
        end
    end




end


