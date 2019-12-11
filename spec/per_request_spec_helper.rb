require "rspec/core"
require "vcr"
require_relative "../lib/main"

## Configuration
def path_query_fragment(uri)
  uri = URI(uri)
  [uri.request_uri, uri.fragment].compact.join("#")
end

VCR.configure do |config|
  config.cassette_library_dir = File.join(
    File.dirname(__FILE__),
    "fixtures/vcr_cassettes/per_request"
  )
  config.hook_into :webmock

  config.around_http_request do |request|
    name = path_query_fragment(request.uri)
    record = ENV.fetch("VCR_RECORD", :none).to_sym

    VCR.use_cassette(name, record: record, &request)
  end
end