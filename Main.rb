require 'sinatra'
require './Student'
require 'sinatra/flash'

enable :sessions

get '/register' do
  @title = "Register"
  erb :register
end

get '/about' do
  @title = "About Us"
  erb :about
end

get '/contact' do
  @title = "Contact Us"
  erb :contact
end

get '/career' do
  @title = "Careers"
  erb :career
end

not_found do
  erb :not_found
end