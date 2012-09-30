require 'net/http'
require 'json'
require 'pp'
require 'thread'

servers_json_url = "https://s3.amazonaws.com/cheezdev-info/servers.json"

uri = URI.parse(servers_json_url)
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request, data = http.get('/cheezdev-info/servers.json')
servers = JSON.parse data

pages = []
app_servers = servers["cheezburger.common"]
app_servers.each_value do |cluster|
  cluster.each do |server|
    pages << "http://#{server["hostname"]}/iamwho"
  end
end


threads = []
semaphore = Mutex.new

for page in pages
  threads << Thread.new(page) { |myPage|

    uri = URI.parse(myPage)
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 4000
    http.open_timeout = 4000
 
    success = true
    resp, data = http.get(uri.path) rescue success = false
    
    semaphore.synchronize {
      if success 
        printf "Response: %-60s %s\n", myPage, resp.code
      else puts "Failed: #{myPage}" end
    }
  }
end

threads.each { |aThread|  aThread.join }

"http://image1.cheezburger.com/metrics/list"


