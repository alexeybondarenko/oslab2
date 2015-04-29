require 'sinatra'
require 'json'
require 'pry'

class JSONable
    def to_json
        hash = {}
        self.instance_variables.each do |var|
            hash[var.to_s.delete "@"] = self.instance_variable_get var
        end
        hash.to_json
    end
end

class Test < JSONable

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
