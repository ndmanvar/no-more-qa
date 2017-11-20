# USAGE: ruby create_test.rb <SESSION_ID>

require 'rest-client'
require 'json'

# SESSION_ID = ARGV[0]
# raise "No session ID as parameter" if SESSION_ID.nil?

require 'uri'
require 'net/http'

url = URI("https://api.sessionstack.com/v1/websites/2319/sessions/5a12543e7a7c26a22ac0747b/export")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request["authorization"] = 'Basic bm1hbnZhcjIwMDAtc2Vzc2lvbnN0YWNrQHlhaG9vLmNvbToxNGY0ZThhNWRlMWM0NzQ3OWEwOGI3Zjk4ZmFlZjk5YQ=='
request["cache-control"] = 'no-cache'
request["postman-token"] = '757edf20-09ff-bde9-7e5c-1e802cf7d463'

response = http.request(request)
response = JSON.parse(response.read_body)
events = response['events']

initialState_nodes = response['initialState']['snapshot']['childNodes']

def get_sessionstack_node(sessionstack_id)
        
    # USE RECURISION!!! NEIL IS HERE
    # OR maybe not use recursion
    # use sessionstack_id as HASH function. if sessionstack_id < or == or > curr_id. i.e. be smart about it
    counter = 0
    nodes = initialState_nodes
    while (nodes[counter]['id'] != )
    end
end

test_location = "generated_tests/freshly_created_test.rb"
spec_location = "generated_tests/freshly_created_spec.txt"

File.open(test_location, "w") do | file |
    File.open(spec_location, "w") do | spec_file |
        # TODO: host/testEnv should not be hardcoded
        url = "file:///Users/neilmanvar/git/random/no-more-qa/app/app.html"
        spec_file.write "launch_browser #{url}\n"

        last_key_testId = nil
        for event in events
            case event['type']
            when 'mouse_click'
                id = event['data']['selector']['id'] if event['data']['selector'].nil?
                spec_file.write "click #{id}\n" unless id.nil?
            when 'dom_element_value_change'
                # id = event['data']['selector']['id'] if event['data']['selector'].nil?
                sessionstack_id = event['data']['id']
                
                if id.nil?
                    puts "No idea detected for #{event['data']}" # TODO: figure out what to do for not "identified" elements
                else
                    if last_key_testId == id
                        spec_file.truncate(spec_file.size - 1) # remove last character (newline)
                        spec_file.pos -= 1
                        spec_file.write("#{event['data']['value']}\n")
                    else
                        spec_file.write "key #{id} #{event['data']['value']}\n"
                    end
                    last_key_testId = id
                end
            else
                # TODO: Handle gracefully
                # raise "Error: Event not implemented"
            end

            # TODO: Track URL changes
        end
        spec_file.write "close_browser\n"
    end
end

# Temporarily still output generated test script
# puts IO.read(spec_location)
