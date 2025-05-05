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
    db.execute('DROP TABLE IF EXISTS wishlist')
    db.execute('DROP TABLE IF EXISTS favorites')
  end

  def self.create_tables
     db.execute("CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      email TEXT NOT NULL,
      password TEXT NOT NULL,
      description TEXT NOT NULL DEFAULT '',
      country TEXT NOT null,
      role TEXT NOT NULL DEFAULT 'user'
      )")

      db.execute("CREATE TABLE wishlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        game_id INTEGER NOT NULL

      )")

      db.execute("CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        game_id INTEGER NOT NULL
      )")

  end

  def self.populate_tables
    password_hashed2 = BCrypt::Password.create("296")
    db.execute('INSERT INTO users (username, email, password, description, country, role ) VALUES (?,?,?,?,?,?)', ["Flusek", "Elias.jadefrid@gmail.com" , password_hashed2 , "Jag heter elias.", "Sweden", "admin"])

  end

  
  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/spel.sqlite')
    @db.results_as_hash = true
    @db
  end

end
