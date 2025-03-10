require 'sqlite3'
require 'bcrypt'


class Seeder

  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS users')
  end

  def self.create_tables
     db.execute('CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password integer,
      description TEXT NOT NULL,
      cuntry TEXT NOT null,
      city TEXT NOT Null,
      role text
      )')

  end

  def self.populate_tables
    password_hashed2 = BCrypt::Password.create("296")
    db.execute('INSERT INTO users (username, password, description, cuntry, city, role ) VALUES (?,?,?,?,?,?)', ["Flusek", password_hashed2 , "Jag heter elias.", "Sweden", "Gothenburg", "admin"])

  end

  
  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/spel.sqlite')
    @db.results_as_hash = true
    @db
  end

end
