Gem::Specification.new do |s|
  s.name        = 'deviantart-oauth2'
  s.version     = '0.1.2.4'
  s.date        = '2012-06-29'
  s.summary     = "Unofficial wrapper for Deviantart OAuth 2.0 API"
  s.description = "This gem contains class DeviantClient which helps use some Deviantart OAuth 2.0 API (load file to sta.sh, take user whois etc)"
  s.authors     = ["Tauraloke"]
  s.email       = ["tauraloke@gmail.com"]
  s.homepage    = "http://github.com/tauraloke/deviantart"
  s.files       = ["lib/deviantart.rb"]
  s.add_dependency(%q<json>, [">= 0"])
  s.add_dependency(%q<rest-client>, [">= 0"])
end
