require 'rubygems'
require 'open-uri'
require 'json'
require 'yaml'
require 'rest-client'



class DeviantClient
  attr_accessor :key
  attr_accessor :secret
  attr_accessor :access_token
  attr_accessor :refresh_token
  OAUTH_PATH = 'https://www.deviantart.com/oauth2/draft15/'
  API_PATH = 'https://www.deviantart.com/api/draft15/'

  def initialize key=nil, secret=nil
	@key = key
	@secret = secret
  end
  
  def authorization_url params = {}
	redirect_uri = (params.has_key? :redirect_uri) ? params[:redirect_uri] : ''
	url = OAUTH_PATH + 'authorize?client_id=' + @key + '&redirect_uri=' + redirect_uri + '&display=page&response_type=code'
  end
  
  def get_token params
    code = params[:code] ? params[:code] : ''
    url = OAUTH_PATH + 'token?client_id=' + @key + '&client_secret=' + @secret + '&code=' + code + '&grant_type=authorization_code'
    begin
	  page = open(url)
		data = JSON.parse(page.read)
		@access_token = data['access_token']
		@refresh_token = data['refresh_token']
	rescue Exception=>e
		refresh
	end
  end
  
  def refresh
    url = OAUTH_PATH + 'token?client_id=' + @key + '&client_secret=' + @secret + '&refresh_token=' + @refresh_token + '&grant_type=refresh_token'
    begin
	  page = open(url)
	  data = JSON.parse(page.read)
	  @access_token = data['access_token']
	  @refresh_token = data['refresh_token']
	rescue Exception=>e
		raise 'Trying refresh token but fail. Is refresh_token expired?'
	end
  end
  
  def fetch resource
    url = API_PATH + resource + '?access_token=' + @access_token
    #require 'pp'; pp url;
    begin
      page = open(url)
      data = JSON.parse(page.read)
      return data
    rescue
	  raise 'Trying fetch resource "'+resource+'" but fail.'
    end
  end
  
  def post resource, options={}, filepath=nil
    url = API_PATH + resource + '?access_token=' + @access_token
    url = url + '&' + options.map{ |k,v| "#{k}="+URI::encode(v) }.join('&') if options
    begin
      response = RestClient.post url, filepath ? { :file => File.new(filepath, 'rb') } : nil
      return JSON.parse(response.to_str)
    rescue Exception=>e
		pp e
		raise 'Trying post data but fail'
    end
  end
  

  def placebo
	begin
      fetch 'placebo'
      rescue
        refresh
      end
  end

  def whoami
    fetch 'user/whoami'
  end

  def damntoken
    data = fetch 'user/damntoken'
    return data['damntoken'] 
  end
  
  def stash_space
    data = post 'stash/space'
    return data['available_space']
  end
  
  def submit params
    option_keys = [:title, :artist_comments, :keywords, :stashid, :folder, :folderid]
    options = {  }
    option_keys.each do |key|
	  options[key] = params[key] if params[key]
    end
    data = post 'stash/submit', options, params[:file]
    data['link'] = 'http://sta.sh/0'+data['stashid'].to_i.to_s(36)
    return data
  end

end
