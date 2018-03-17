# USAGE: ruby create_test.rb <PROJ_ID> <SESSION_ID>

require 'rest-client'
require 'json'

# PROJ_ID = ARGV[0] # do we need PROJ_ID?
SESSION_ID = ARGV[0]
raise "Not passing proper parameters" if SESSION_ID.nil? # or PROJ_ID.nil?

# TODO: replace with proper request library/gem
require 'uri'
require 'net/http'
url = URI("https://api.sessionstack.com/v1/websites/2319/sessions/#{SESSION_ID}/export") # TO DO: replace with correct session
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
request = Net::HTTP::Get.new(url)
# TODO: key/authorization should be ENV var and/or securely passed in
request["authorization"] = 'Basic bm1hbnZhcjIwMDAtc2Vzc2lvbnN0YWNrQHlhaG9vLmNvbToxNGY0ZThhNWRlMWM0NzQ3OWEwOGI3Zjk4ZmFlZjk5YQ=='
request["cache-control"] = 'no-cache'
request["postman-token"] = '757edf20-09ff-bde9-7e5c-1e802cf7d463'
response = http.request(request)
response = JSON.parse(response.read_body)
events = response['events']

$initialState_nodes = response['initialState']['snapshot']['childNodes'] # TODO: childNodes might not always exist like this

# returns [] of sessionstack nodes. parses initialState DOM tree and flattens in to array.
def flatten(nodes)
    # probably the most insane way to flatten, but who cares for POC/MVP
    # this would be frowned upon by all the programmers I look up to,
    # and all of my professors at UC Davis. I'm sorry.
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

def clean_events(events)
    counter = 1
    scrubbed_events = []
    while counter < events.size and events[counter] != nil do
        event = events[counter]
        prev_event = events[counter-1]
        if event['type'] == 'dom_element_value_change' and prev_event['type'] == 'dom_element_value_change'
            puts "\n\nprev event is    : #{prev_event}"
            puts "current event is : #{event}\n"
            if prev_event['data']['id'] == event['data']['id']
                scrubbed_events.push(prev_event)
                puts "SCRUBBING: #{prev_event}"
            end
        end
        counter += 1
    end
    return events - scrubbed_events
end
events = clean_events(events)
# puts "clean events is : #{events}"

# grabs value of 
def get_sessionstack_node_value(id)
    # could be more efficient here
    node = $initialState_nodes.find{ | elem | elem['id'] == id }
    id_attr = node['attributes'].find { | elem | elem['name'] == 'id' }
    return id_attr['value']
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
                id = event['data']['selector'][0]['id']
                tag_name = event['data']['selector'][0]['tagName']
                spec_file.write "click #{id}\n" unless id.nil? or tag_name == 'HTML' or tag_name == 'BODY'
            when 'dom_element_value_change'
                id = event['data']['id']

                # could be more efficient here
                key_value = get_sessionstack_node_value(id)
                
                if id.nil?
                    puts "No id detected for #{event['data']}" # TODO: figure out what to do for not "identified" elements
                else
                    if last_key_testId == id
                        # spec_file.seek(-1, IO::SEEK_CUR)
                        # spec_file.seek(-1, IO::SEEK_CUR)
                        # spec_file.truncate(spec_file.size - 1) # remove last character (newline)
                        # spec_file.pos -= 1
                        spec_file.write("key #{key_value} #{event['data']['value']}\n")
                    else
                        spec_file.write "key #{key_value} #{event['data']['value']}\n"
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
