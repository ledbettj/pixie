require 'sinatra'
require 'sinatra/base'
require 'json'

module Pixie
  class Web < Sinatra::Application
    begin
      require 'sinatra/reloader'
      register Sinatra::Reloader
      puts 'Hot reloading enabled'
    rescue LoadError
      puts 'Hot reloading disabled'
    end

    set :port, 3000
    set :bind, '0.0.0.0'
    set :public_folder, File.expand_path('./web', __dir__)

    get '/' do
      send_file File.join(settings.public_folder, 'index.html')
    end

    get '/effects.json' do
      content_type 'application/json'
      JSON.dump(driver.as_json)
    end

    delete '/effects/:index' do
      content_type 'application/json'
      index = params['index'].to_i
      driver.remove(index)
      JSON.dump(driver.as_json)
    end

    post '/effects/:index' do
      content_type 'application/json'
      index = params['index'].to_i
      conf = JSON.parse(request.body.read)
      conf.transform_keys!{|k| k.to_sym}
      driver.stack[index].reconfigure(**conf)
      JSON.dump(driver.stack[index].as_json)
    end

    private

    def driver
      settings.driver
    end
  end
end
