require "sinatra/base"
require 'json'
require 'yaml'

class Logr < Sinatra::Base
	post '/logr' do
		@config = YAML.load(File.read(File.join(File.dirname(__FILE__), 'config.yml')))
		@data_path = File.join(File.expand_path(File.dirname(__FILE__)), @config['relative_data_path'])

		data = JSON.parse request.body.read
		if data['token'] == @config['token']
			data.delete('token')
			log data
		else
			status 401
		end
		return
	end

	def log data
		prefix = ''
		if @config.has_key?('prefix')
			prefix = @config['prefix']
		end
			
		filename = File.join(@data_path, prefix + Time.now.utc.strftime("%F") + '.log')
		File.open(filename, 'a') do |f|
			f.write JSON.generate(data) + "\n"
		end
	end

	not_found do
	  status 444
	end
end
