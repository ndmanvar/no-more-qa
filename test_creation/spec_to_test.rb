# USAGE: ruby spec_to_test.rb

require 'rest-client'
require 'json'

# hit_the_api to get each individual event / test step
# TODO: Add authentication.

# TODO: not hardcode spec and test locations
test_location = "generated_tests/freshly_created_test.rb"
spec_location = "generated_tests/freshly_created_spec.txt"

File.open(spec_location, "r") do | spec_file |
    File.open(test_location, "w") do | file |
        spec_file.each_line do |line|
            event = line.split(" ")

            case event[0]
            when 'launch_browser'
                file.write "# ------------------BEGIN TEST------------------\n"
                file.write "require 'watir-webdriver'\n"
                file.write "browser = Watir::Browser.new :chrome\n" # TODO. Add browser support
                # Timeout = 15 sec # TODO: configurable timeouts
                file.write "browser.goto \"#{event[1]}\"\n"
            when 'close_browser'
                file.write "browser.quit()\n"
                file.write "# ------------------END TEST------------------\n"
                file.write "puts \"Success!\\n\\n\""
            when 'click'
                # TODO: add wait
                file.write "\nbrowser.element(:css => \"*[test-id='#{event[1]}']\").when_present.click()\n"
            when 'key'
                file.write "\nbrowser.element(:css => \"*[test-id='#{event[1]}']\").when_present.send_keys(\"#{event[2]}\")\n"
            else
                raise 'error: TODO'
            end
        end
        
    end
end

# Temporarily still output generated test script
puts IO.read(test_location)
