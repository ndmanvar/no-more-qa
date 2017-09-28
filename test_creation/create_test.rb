# USAGE: ruby create_test.rb <SESSION_ID>

require 'rest-client'
require 'json'

SESSION_ID = ARGV[0]
raise "No session ID as parameter" if SESSION_ID.nil?

# hit_the_api to get each individual event / test step
# TODO: Add authentication.
res = RestClient.get("http://localhost:3000/getevents/#{SESSION_ID}")
events = JSON.parse(res.body)

puts "------------------BEGIN TEST------------------"
puts "require 'selenium-webdriver'"
puts "@browser = Selenium::WebDriver.for :chrome"
# TODO: host/testEnv should not be hardcoded
puts "@browser.get \"file:///Users/neilmanvar/git/random/no-more-qa/app.html\""
for event in events
    # TODO: make into switch/scase statement
    if event['event_type'] == 'click'
        puts "@browser.find_element(:css => \"*[test-id='#{event['event_testId']}']\").click()"
    elsif event['event_type'] == 'key'
        puts "@browser.find_element(:css => \"*[test-id='#{event['event_testId']}']\").send_keys(\"#{event['event_value']}\")"
    else
        # TODO: Handle gracefully
        puts 'Not implemented'
    end
end
puts "@browser.quit()"
puts "------------------END TEST------------------"
