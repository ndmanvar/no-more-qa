# USAGE: ruby spec_to_test.rb

require 'rest-client'
require 'json'

# hit_the_api to get each individual event / test step
# TODO: Add authentication.

# TODO: not hardcode spec and test locations
test_location = "generated_tests/freshly_created_test.rb"
spec_location = "generated_tests/freshly_created_spec.nmqa"

File.open(spec_location, "r") do | spec_file |
    File.open(test_location, "w") do | file |
        spec_file.each_line do |line|
            event = line.split(" ")

            case event[0]
            when 'launch_browser'
                file.write "# ------------------BEGIN TEST------------------\n"
                file.write "require 'selenium-webdriver'\n"
                file.write "@browser = Selenium::WebDriver.for :chrome\n" # TODO. Add browser support
                
                file.write "@browser.get \"#{event[1]}\"\n"
            when 'close_browser'
                file.write "@browser.quit()\n"
                file.write "# ------------------END TEST------------------\n"
            when 'click'
                # TODO: add wait
                file.write "@browser.find_element(:css => \"*[test-id='#{event[1]}']\").click()\n"
            when 'key'
                file.write "@browser.find_element(:css => \"*[test-id='#{event[1]}']\").send_keys(\"#{event[2]}\")\n"
            else
                raise 'error: TODO'
            end
        end
        
    end
end

# Temporarily still output generated test script
puts IO.read(test_location)
