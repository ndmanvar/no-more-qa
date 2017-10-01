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
File.open(test_location, "w") do | file |
    
    file.write "# ------------------BEGIN TEST------------------\n"
    file.write "require 'selenium-webdriver'\n"
    file.write "@browser = Selenium::WebDriver.for :chrome\n"
    # TODO: host/testEnv should not be hardcoded
    file.write "@browser.get \"file:///Users/neilmanvar/git/random/no-more-qa/app.html\"\n"
    for event in events
        case event['event_type']
        when 'click'
            file.write "@browser.find_element(:css => \"*[test-id='#{event['event_testId']}']\").click()\n"
        when 'key'
            file.write "@browser.find_element(:css => \"*[test-id='#{event['event_testId']}']\").send_keys(\"#{event['event_value']}\")\n"
        else
            # TODO: Handle gracefully
            file.write 'Not implemented\n'
        end
    end
    file.write "@browser.quit()\n"
    file.write "# ------------------END TEST------------------\n"
end

# Temporarily still output generated test script
puts IO.read(test_location)
