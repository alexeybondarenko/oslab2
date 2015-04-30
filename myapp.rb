require 'sinatra'
require 'json'
require 'pry'
require 'virtus'

class Test 
    include Virtus.model

	attr_reader :id, :name

	def initialize(id, name)
		@id = id
		@name = name
	end
end

# binding.pry

get '/' do
	Test.new(1, "gogi").to_json
end
