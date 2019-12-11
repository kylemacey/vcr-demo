require "rspec/core"
require "vcr"
require_relative "../lib/main"

## Configuration
VCR.configure do |config|
  config.cassette_library_dir = File.join(
    File.dirname(__FILE__),
    "fixtures/vcr_cassettes/per_example"
  )
  config.hook_into :webmock
  config.configure_rspec_metadata!
end