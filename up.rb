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
    pages << "http://#{server["hostname"]}/iamwho?format=json"
  end
end

def print_server_info(url, response, response_time)
  begin
    server_info = JSON.parse response.body 
    version = server_info["ApplicationReleaseTag"]["value"]
  rescue
    version = "UNKNOWN_ERROR"
  end
  printf "Response: %-60s %-5s%-10s%-20s\n", url, response.code, response_time, version
end

threads = []
semaphore = Mutex.new

for page in pages
  threads << Thread.new(page) { |myPage|
    
    start_time = Time.now

    uri = URI.parse(myPage)
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 4
    http.open_timeout = 4
 
    success = true
    resp = http.get(uri.request_uri) rescue success = false
    end_time = Time.now
    delta = end_time - start_time
    semaphore.synchronize {
      if (success && resp.code == "200")
        print_server_info myPage, resp, delta 
      else puts "Failed: #{myPage}\t#{delta}" end
    }
  }
end

threads.each { |aThread|  aThread.join }

"http://image1.cheezburger.com/metrics/list"


