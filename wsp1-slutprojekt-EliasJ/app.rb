
require 'sinatra'
require 'json'
require 'sinatra/cross_origin'
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

    before do
        response.headers['Access-Control-Allow-Origin'] = '*'
    end

    enable :sessions

    get '/api/loggin' do 
        users = db.execute('SELECT * FROM users')
        content_type :json
       {users: users}.to_json
   
    end




end


