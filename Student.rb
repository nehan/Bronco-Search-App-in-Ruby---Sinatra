require 'dm-core'
require 'dm-migrations'



DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3:bronco.db")

enable :sessions

db= 'bronco.db'

class Contact 
include DataMapper::Resource
property :row_id, Serial
property :fullname, String
property :subject, String
property :email, String
property :comments, String
end

class Student
  include DataMapper::Resource
  property :row_id, Serial
  property :first_name, String
  property :last_name, String
  property :scu_email, String
  property :registered_on, Date
  property :program_name, String
  property :specialization, String
  property :expected_grad_year, String
  property :courses, Text
  property :username, String
  property :password, String
end

DataMapper.finalize
if File.exists?(db)
    DataMapper.auto_upgrade!
else
    DataMapper.auto_migrate! # erases and creates the database. 
	Student.auto_migrate!
	Contact.auto_migrate!
end

get '/' do
  @title = "Login"
  erb :login
end

post '/register/new' do
data=params[:student]
conf_pass=params[:student_pass]
@students=Student.all(:username => data[:username])
if data[:password]!= conf_pass[:conf_password]
flash[:error_password] ="Password doesn't Match!!"
redirect to("/register")
else
if @students.empty?
student = Student.create(params[:student])
student.registered_on= Time.now.strftime("%B %e, %Y")
student.save
redirect to("/")
else
flash[:error] ="Username Already Exists!"
redirect to("/register")
end
end
end

get '/welcome' do
data=params[:student]
if data[:username].empty? && data[:password].empty?
	 flash[:error] ="Username and password is empty!"
	 redirect to ("/")
elsif data[:username].empty?
	flash[:error_password] = "Username should not be empty."
	redirect to ("/")
elsif data[:password].empty?
    flash[:error_user] = "Password should not be empty." 
  	redirect to ("/")
else
@students=Student.all(:username => data[:username],:password => data[:password])
	if @students.empty?
		erb :errorpage 
	else
		erb :welcome
	end
end
end

post '/welcome/:user' do
stud = Student.all(:username => params[:user])
stud.update(params[:student])
stud.save
username=params[:user]
redirect to("/welcome_new/#{username}")
end

get '/welcome_new/:username' do
@students = Student.all(:username => params[:username])
erb :welcome
end


get '/details/:username' do
@students = Student.all(:username => params[:username])
erb :details
end

get '/edit/:mail' do
  @title = "Edit your profile"
  @student_data=Student.all(:scu_email => params[:mail])
  erb :edit
end

delete '/delete/:user' do
  student=Student.all(:username => params[:user])
  student.destroy
  student.save
  redirect to('/delete_confirm')
end

get '/delete_confirm' do
  erb :delconfirm
end

get '/search/:username' do
data=params[:student]
@username=params[:username]
@student_data=Student.all(:first_name.like => "%#{data[:first_name]}%")
if @student_data.empty?
@no_data=true
end
erb :search
end

post '/savecontact' do
contact = Contact.create(params[:contact])
contact.save
erb :savecontact
end