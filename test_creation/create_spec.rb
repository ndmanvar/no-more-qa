# USAGE: ruby create_test.rb <SESSION_ID>

require 'rest-client'
require 'json'

SESSION_ID = ARGV[0]
raise "No session ID as parameter" if SESSION_ID.nil?

# hit_the_api to get each individual event / test step
# TODO: Add authentication.
res = RestClient.get("http://localhost:3000/getevents/#{SESSION_ID}")
events = JSON.parse(res.body)

test_location = "generated_tests/freshly_created_test.rb"
spec_location = "generated_tests/freshly_created_spec.txt"

File.open(test_location, "w") do | file |
    File.open(spec_location, "w") do | spec_file |
        # TODO: host/testEnv should not be hardcoded
        url = "file:///Users/neilmanvar/git/random/no-more-qa/app/app.html"
        spec_file.write "launch_browser #{url}\n"

        last_key_testId = nil
        for event in events
            case event['event_type']
            when 'click'
                spec_file.write "click #{event['event_testId']}\n"
            when 'key'
                if last_key_testId == event['event_testId']
                    spec_file.truncate(spec_file.size - 1) # remove last character (newline)
                    spec_file.pos -= 1
                    spec_file.write("#{event['event_value']}\n")
                else
                    spec_file.write "key #{event['event_testId']} #{event['event_value']}\n"
                end
                last_key_testId = event['event_testId']
            else
                # TODO: Handle gracefully
                raise "Error: Event not implemented"
            end

            # TODO: Track URL changes
        end
        spec_file.write "close_browser\n"
    end
end

# Temporarily still output generated test script
# puts IO.read(spec_location)
