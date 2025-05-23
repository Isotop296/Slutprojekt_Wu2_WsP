require 'sinatra'
require 'json'
require 'sinatra/cross_origin'
require 'bcrypt'
require 'sqlite3'
require 'jwt'
require 'dotenv/load'
require 'httparty'


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

    before do
      response.headers["Access-Control-Allow-Origin"] = "http://localhost:5173"
      response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
      response.headers["Access-Control-Allow-Credentials"] = "true"
    end
    
    options "*" do
      response.headers["Access-Control-Allow-Origin"] = "http://localhost:5173"
      response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
      response.headers["Access-Control-Allow-Credentials"] = "true"
      200
    end
  

    def authenticated_user(token)
      if token
        begin
          payload = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' }).first
          user_id = payload["user_id"]
          return user_id
        rescue JWT::DecodeError
          halt 401, { message: "Invalid token" }.to_json
        end
      else
        halt 401, { message: "Missing token" }.to_json
      end
    end


    get '/api/users' do
      puts "start of users"
      token = request.cookies["token"]
      puts "token: #{token}"
      user_id = authenticated_user(token)
      puts "user id: #{user_id}"
    
      if user_id
        user = db.execute("SELECT * FROM users WHERE id = ?", [user_id])
        puts "user: #{user}"
        if user
          status 200
          content_type :json
          user.to_json
        else
          status 404
          { error: "User not found" }.to_json
        end
      else
        status 401
        { error: "Unauthorized" }.to_json
      end
    end


    post '/api/users/update' do
      token = request.cookies["token"]
    
      user_id = authenticated_user(token)

      request_body = request.body.read
      requested_data = JSON.parse(request_body)

      username = requested_data["username"]
      description = requested_data["description"]
      puts "username: #{username}"
      puts "Description: #{description}"
      
      begin
        db.execute("UPDATE users SET username = ?, description = ? WHERE id = ?", [username, description, user_id])
        status 200
        { message: 'User info updated successfully' }.to_json
      rescue => e
        status 500
        { error: 'Database error', details: e.message }.to_json
      end

    end


    post "/api/users/logout" do
      response.set_cookie("token", {
        value: "",
        path: "/", 
        expires: Time.at(0), 
        same_site: "Lax",     
        secure: true,         
        httponly: true       
      })
    
    
      status 200
      json({ message: "Logged out" })
    end

    
    post '/api/users/login' do
        begin
          request_data = JSON.parse(request.body.read)

          email = request_data["email"]
          password = request_data["password"]
      
          user = db.execute('SELECT * FROM users WHERE email = ?', [email]).first
      
          if user && BCrypt::Password.new(user["password"]) == password
            payload = { user_id: user["id"] }
            jwt_token = JWT.encode(payload, SECRET_KEY, 'HS256')

            response.set_cookie(
              "token",
              value: jwt_token,
              path: "/",
              httponly: true,   # skyddar från JavaScript
              secure: false,     # endast via HTTPS
              same_site: "Lax", # skyddar mot CSRF
              expires: Time.now + 60 * 60 * 24 
            )            
      
            status 200
            content_type :json
            { message: "Login successful"}.to_json
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


    post '/api/users/create_account' do
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


            db.execute('INSERT INTO users (email, password, username, country) 
                VALUES (?, ?, ?, ?)',[email, password_digest, username, country])

            new_user = db.execute('SELECT * FROM users WHERE email = ?', [email]).first

            payload = { user_id: new_user["id"] }
            jwt_token = JWT.encode(payload, SECRET_KEY, 'HS256')


            response.set_cookie(
            "token",
            value: jwt_token,
            path: "/",
            httponly: true,   # skyddar från JavaScript
            secure: false,     # endast via HTTPS
            same_site: "Lax", # skyddar mot CSRF
            expires: Time.now + 60 * 60 * 24 
)

            status 200
            content_type :json
            { message: "Account created successfully" }.to_json

            rescue => e
                status 500
                content_type :json
                { message: "Server error", error: e.message }.to_json
            end
        end

        post "/api/GetGameByGenre" do
          request_body = request.body.read
          requested_data = JSON.parse(request_body)

          genre = requested_data["genre"]
          page = requested_data["page"]
        
          rawg_key = ENV['RAWG_KEY']
          rawg_url = "https://api.rawg.io/api/games?genres=#{genre}&page=#{page}&page_size=8&key=#{rawg_key}"
        
          response = HTTParty.get(rawg_url)
        
          data = JSON.parse(response.body)
          games = data["results"]
        
          games_with_descriptions = games.map do |game|
            game_id = game["id"]
            details_url = "https://api.rawg.io/api/games/#{game_id}?key=#{rawg_key}"
            details_response = HTTParty.get(details_url)
        
            next unless details_response.code == 200
        
            game_details = JSON.parse(details_response.body)
        
            has_banned_genre = game_details["tags"].any? do |tag|
              tag["name"].downcase.include?("sex")
            end
        
            next if has_banned_genre
        
            game["description"] = game_details["description"]
            game
          end
        
          games_with_descriptions.compact! 
        
          content_type :json
          games_with_descriptions.to_json
        end
        

        get "/api/GetTopGames" do
            key = ENV["RAWG_KEY"]
            url = "https://api.rawg.io/api/games?ordering=-rating&page=1&page_size=5&key=#{key}"
            response = HTTParty.get(url)
            games = JSON.parse(response.body)["results"]
          
            games_with_descriptions = games.map do |game|
              game_id = game["id"]
              details_url = "https://api.rawg.io/api/games/#{game_id}?key=#{key}"
              details_response = HTTParty.get(details_url)
          
              next unless details_response.code == 200
          
              game_details = JSON.parse(details_response.body)
          
              has_banned_genre = game_details["tags"].any? do |genre|
                genre["name"].downcase.include?("sex")
              end
          
              next if has_banned_genre
          
              game["description"] = game_details["description"]

              # Kan användas för att ha fler bilder av varje spel, tänkte använda den för att ha en galleria av bilderna i slideshowen men lyckades inte.
              # game["screenshots"] = game_details["short_screenshots"].map { |screenshot| screenshot["image"] } if game_details["short_screenshots"]

              game
            end
          
            games_with_descriptions.compact!
          
            content_type :json
            games_with_descriptions.to_json
          end
          
          
        # get "/api/GetGameDetails" do
        #     id = params[:id]
        #     key = ENV["RAWG_KEY"]
        #     url = "https://api.rawg.io/api/games/#{id}?key=#{key}"
          
        #     response = HTTParty.get(url)
        #     content_type :json
        #     response.body
        #   end
          


          post "/api/favorites/new" do
            token = request.cookies["token"]
            begin             
              user_id = authenticated_user(token)

              request_body = request.body.read
              requested_data = JSON.parse(request_body)
              game_id = requested_data["game_id"]

              existing_favorite = db.execute('SELECT 1 FROM favorites WHERE user_id = ? AND game_id = ?', [user_id, game_id])
             
              if existing_favorite.empty?
              db.execute('INSERT INTO favorites (user_id, game_id) VALUES (?, ?)', [user_id, game_id])
          
              status 200
              content_type :json
              { message: "Game added to favorites" }.to_json
            else
              status 400
              content_type :json
              { message: "Game is already in favorites" }.to_json
            end
          
            rescue JWT::DecodeError => e
              status 401
              content_type :json
              { message: "Invalid token", error: e.message }.to_json
            end
          end
          
          
          post "/api/wishlist/new" do
            token = request.cookies["token"]
          
            begin
              user_id = authenticated_user(token)
          
              request_body = request.body.read
              requested_data = JSON.parse(request_body)
              game_id = requested_data["game_id"]

              existing_wishlist = db.execute('SELECT 1 FROM wishlist WHERE user_id = ? AND game_id = ?', [user_id, game_id])
             
              if existing_wishlist.empty?
              db.execute('INSERT INTO wishlist (user_id, game_id) VALUES (?, ?)', [user_id, game_id])
          
              status 200
              content_type :json
              { message: "Game added to wishlist" }.to_json
            else
              status 400
              content_type :json
              { message: "Game is already in wishlist"}.to_json
            end
          
          
            rescue JWT::DecodeError => e
              status 401
              content_type :json
              { message: "Invalid token", error: e.message }.to_json
            end
          end



          get '/api/favorites' do
            begin
              token = request.cookies["token"]

              user_id = authenticated_user(token)

              favorites = db.execute('SELECT game_id FROM favorites WHERE user_id = ?', [user_id])
      
              status 200
              content_type :json
              favorites.to_json
            rescue => e
              status 401
              content_type :json
              puts "status 401 favorit"
              { message: "Unauthorized", error: e.message }.to_json
            end
          end

          get '/api/wishlist' do
            begin
              token = request.cookies["token"]

              user_id = authenticated_user(token)

              wishlist = db.execute('SELECT game_id FROM wishlist WHERE user_id = ?', [user_id])
              puts wishlist
              status 200
              content_type :json
              wishlist.to_json
            rescue => e
              status 401
              puts "status 401 wishlist"
              content_type :json
              { message: "Unauthorized", error: e.message }.to_json
            end
          end

          post '/api/getgames' do
            request_body = request.body.read
            requested_data = JSON.parse(request_body)
          
            game_batch1 = requested_data["game_batch1"] || []
            if game_batch1.empty?
              status 400
              content_type :json
              puts "status 400"
              return { message: "No games provided" }.to_json
            end
          
            key = ENV["RAWG_KEY"]
            games_info = []
          
            game_batch1.each do |game|
              url = "https://api.rawg.io/api/games/#{game["game_id"]}?key=#{key}"
              response = HTTParty.get(url)
    
              if response.code == 200
                games_info << response.parsed_response
              else
                puts "Failed to fetch game details for ID: #{game["id"]}"
              end
            end
          
            content_type :json
            games_info.to_json
          end
          
          post "/api/removegame" do 
            token = request.cookies["token"]

            request_body = request.body.read
            requested_data = JSON.parse(request_body)

            game_id = requested_data["gameid"]
            type = requested_data["type"]
            user_id = authenticated_user(token)
            # puts "game id: #{game_id}"
            # puts "type: #{type}"
            # puts "user id: #{user_id}"

            if type == "favorite"
              db.execute('DELETE FROM favorites WHERE game_id = ? AND user_id = ?', [game_id, user_id])
              status 200
              content_type :json
              { message: "Game removed from favorites" }.to_json
            elsif type == "wishlist"
              db.execute('DELETE FROM wishlist WHERE game_id = ? AND user_id = ?', [game_id, user_id])
              status 200
              content_type :json
              { message: "Game removed from wishlist" }.to_json
            else
              status 400
              content_type :json
              { message: "Invalid type specified" }.to_json
            end
          end
     
          

end


