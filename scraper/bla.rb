require 'httparty'

response = HTTParty.get("/home/hosting/scraper/fake.html")
puts response.code

# file = File.write("fake.html", response.body.to_s)
