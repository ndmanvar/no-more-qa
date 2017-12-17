# USAGE: ruby create_test.rb <SESSION_ID>

require 'rest-client'
require 'json'

# SESSION_ID = ARGV[0]
# raise "No session ID as parameter" if SESSION_ID.nil?

require 'uri'
require 'net/http'

url = URI("https://api.sessionstack.com/v1/websites/2319/sessions/5a3619c27d41c305749a0fac/export") # TO DO: replace with correct session

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

$initialState_nodes = response['initialState']['snapshot']['childNodes'] # TODO: childNodes might not always exist like this

def flatten(nodes)
    counter = 0
    
    while counter < nodes.size do
        current_node = nodes[counter]
        if current_node['childNodes'] != nil
            for node in current_node['childNodes']
                nodes.push(node)
            end
            current_node.delete('childNodes')
        end
        counter += 1
    end
    return nodes
end

$initialState_nodes = flatten($initialState_nodes) # TODO: use !

def get_sessionstack_node(sessionstack_id)
        
    # USE RECURISION!!! NEIL IS HERE
    # OR maybe not use recursion
    # use sessionstack_id as HASH function. if sessionstack_id < or == or > curr_id. i.e. be smart about it

    # need to get smarter about searching
    for node in $initialState_nodes
        return node if node["id"] == sessionstack_id
    end
    return nil
end

test_location = "generated_tests/freshly_created_test.rb"
spec_location = "generated_tests/freshly_created_spec.txt"

File.open(test_location, "w") do | file |
    File.open(spec_location, "w") do | spec_file |
        # TODO: host/testEnv should not be hardcoded
        url = "file:///Users/neilmanvar/git/random/no-more-qa/app/app.html"
        spec_file.write "launch_browser #{url}\n"

        last_key_testId = nil

        puts "events is #{events}"
        for event in events
            case event['type']
            when 'mouse_click'
                # require 'pry'; binding.pry
                id = event['data']['selector'][0]['id']
                spec_file.write "click #{id}\n" unless id.nil?
            when 'dom_element_value_change'
                id = event['data']['id']

                node = get_sessionstack_node(id)
                id_attr = node['attributes'].find { | elem | elem['name'] == 'id' }
                
                if id.nil?
                    puts "No id detected for #{event['data']}" # TODO: figure out what to do for not "identified" elements
                else
                    if last_key_testId == id
                        spec_file.truncate(spec_file.size - 1) # remove last character (newline)
                        spec_file.pos -= 1
                        spec_file.write("#{event['data']['value']}\n")
                    else
                        spec_file.write "key #{id_attr['value']} #{event['data']['value']}\n"
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
