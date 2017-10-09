require 'sqlite3'

db = SQLite3::Database.new "maidchan.db"

db.execute <<-SQL
	CREATE TABLE posts (
		post_id INTEGER PRIMARY KEY AUTOINCREMENT,
		title TEXT,
		comment TEXT NOT NULL,
		parent INTEGER,
		image TEXT,
		ip TEXT,
		author TEXT,
		capcode TEXT
		date_of_creation DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
		date_of_bump DATETIME DEFAULT CURRENT_TIMESTAMP
	);
SQL
