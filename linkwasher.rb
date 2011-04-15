#moze se rjesiti i drukcije pojedinacni zahtjevi primjera radi 
require 'rubygems' if RUBY_VERSION < '1.9' 
require 'sinatra'
require 'sinatra/reloader'
require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'
require 'uri'
require 'erb'
set :show_exceptions, false
set :enviroment, :production
set :dump_errors, false

#ili se rjesava kroz polje.....
#%w(rubygems sinatra haml dm-core dm-timestamps uri).each { |lib| require lib }

#muze se ubaciti templejt i na kraju ali sam ga ja stavio u odvojeni file....

#error do haml :wrong end #pomocna to mi se generira ukoliko rack pukne error 

DataMapper.setup(:default,"sqlite3://#{Dir.pwd}/uruluwassh.sqlite3" || ENV['DATABASE_URL'])
#zadnji parametar sluzi kada se stavlja na hosting primjerice heroku....
#moze bilo koja baza  mysql/postgre u svakom slucaju  dao sam primjer sa sqlite3 
#inace model koji budemo napravili ce vrjediti u sve 3 baze jel koristimo ORM --> DataMapper
#konfiguracija ukoliko koristite mysql ili posgre ide otprilike ovako ima 2 nacina...
#nacin 1
#DataMapper.setup(:default, 'protocol://username:password@localhost:port/path/to/repo')
#nacin 2
#DataMapper.setup(:default, {
#     :adapter  => 'adapter_name_here',
#     :database => "path/to/repo",
#     :username => 'username',
#      :password => 'password',
#     :host     => 'hostname'
#		      })

#pocinjemo  klasu koja nam sadrzi glavni link originalni....
#poslje cemo taj link pretvoriti u numerickoj bazi koristi cmeo id od  Washsimple klase (36)
class Washsimple
   include DataMapper::Resource
   property :id, Serial
   property :originalni, String, :length => 225
   property :kreiran_vrjem, DateTime 
   def washin() self.id.to_s(36) end
end


DataMapper.auto_upgrade!

get '/' do 
 if params[:urlskraceni].nil?
 erb :index
 end
 
end


post '/' do
   uhvati_uri=URI::parse(params[:url])
   if uhvati_uri.kind_of? URI::HTTP or uhvati_uri.kind_of? URI::HTTPS
   @originalni_link=params[:url]
   @dobio_link= Washsimple.first_or_create(:originalni=>uhvati_uri,:kreiran_vrjem=>Time.now)
   erb :shrunk
   else
     redirect '/'
   end
end

get '/:urlskraceni' do
     redirect Washsimple[params[:urlskraceni].to_i(36)-1].originalni ,301 
end

error 500..510 do
   redirect '/'
end
