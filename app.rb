require 'sinatra'
require 'sanitize'
require 'sqlite3'
require 'digest'

db = SQLite3::Database.new "maidchan.db"

set :public_folder, File.dirname(__FILE__) + '/static'
set :port, 80
set :bind, '0.0.0.0'

# Helper functions

types = ['image/png', 'image/jpeg', 'image/gif']

def tripcode!(trip) #Generates a hash out of a tripcode
	return Digest::SHA256.base64digest(trip)[0..10]
end

def store!(params) #Stores the file and returns the filename
	digest = Digest::MD5.new
	digest << params[:file][:filename]
	filename = digest.hexdigest + "." + params[:file][:type].split("image/")[1]

	File.open("./static/images/#{filename}", "wb") do |file|
		file.write(params[:file][:tempfile].read)
	end
	return filename
end

# GET requests, A.K.A. regular routes

get '/' do
	erb :index, :locals => {:db => db}	
end

get '/topic/:id' do |id|
	erb :topic, :locals => {:db => db, :id => id.to_i}
end

# POST requests, A.K.A. functional routes

post '/post' do
        unless params[:name].empty?
                splitted = params[:name].split('#')

                unless splitted[1].nil?
                        name = splitted[0] + "!" + tripcode!(splitted[1])
                else
                        name = splitted[0]
                end
        else
                name = "Anonymous"
        end

	if params[:file] and types.include?(params[:file][:type]) and params[:file][:tempfile].size < 3145728
		filename = store!(params)
		db.execute("INSERT INTO posts (title, comment, author, image) VALUES (?, ?, ?, ?)", params[:title], params[:comment], name, filename)
	else
		db.execute("INSERT INTO posts (title, comment, author) VALUES (?, ?, ?)", params[:title], params[:comment], name)
	end	
	redirect '/', 303
end

post '/reply/:id' do |id|
	db.execute("UPDATE posts SET date_of_bump=CURRENT_TIMESTAMP WHERE post_id=?", id.to_i)

	unless params[:name].empty?
		splitted = params[:name].split('#')
							
		unless splitted[1].nil?
			name = splitted[0] + "!" + tripcode!(splitted[1])
		else
			name = splitted[0]
		end
	else
		name = "Anonymous"
	end

	if params[:file] and types.include?(params[:file][:type]) and params[:file][:tempfile].size < 3145728
		filename = store!(params)
		db.execute("INSERT INTO posts (parent, comment, author, image) VALUES (?, ?, ?, ?)", id.to_i, params[:comment], name, filename)
	else
		db.execute("INSERT INTO posts (parent, comment, author) VALUES (?, ?, ?)", id.to_i, params[:comment], name)
	end
	redirect '/topic/' + id, 303
end
