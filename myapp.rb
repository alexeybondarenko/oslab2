require 'sinatra'
require 'json'
require 'pry'
require './os'

get '/' do
  erb :index
end

get '/processes' do
	OS.new.to_json
end
