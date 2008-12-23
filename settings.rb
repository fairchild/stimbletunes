@settings = {
  :logging => true,
  :port => 4567,
  :session => true,
  :title => 'stimbletunes',
  :url_base => 'http://localhost:4567/',
  :admin_password => 's3cr3t',
  :admin_cookie_key => 'stimbly_admin',
  :admin_cookie_value => '51d6d4450976913ace58',
  :music_dns_api_key => '2010d2dbda0c091010f12cf97b5d9839',
  :music_folders => ['/Users/fairchild/Music/']
  }
  
# if Sinatra.options.env == 'test'
#    @settings.merge({
#   :music_dns_api_key => '2010d2dbda0c091010f12cf97b5d9839',
#   :music_folders => [File.join(File.dirname(__FILE__), 'test', 'fixtures', 'Music')]
#   })
# end