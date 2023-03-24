require "functional/helper"
require "inspec/runner"
require "inspec/resources/file"

describe "inspec report tests" do
  include FunctionalHelper

  describe "report" do
    it "loads a json report" do
      # stub_request(:get, "http://licensing-acceptance.chef.co/License/client?entitlementId&licenseId=tmns-a3a7c4ba-b0fb-46e6-a9d9-5a49c9726158-5859").
      # with(
      #   headers: {
      #   'Accept'=>'*/*',
      #   'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      #   'User-Agent'=>'Faraday v1.10.3'
      #   }).
      # to_return(status: 200, body: "", headers: {})
      WebMock.allow_net_connect!
      o = { "reporter" => ["json"], "report" => true }
      runner = ::Inspec::Runner.new(o)
      runner.add_target(example_profile)
      runner.run
      _(runner.report.count).must_equal 4
      _(runner.report.inspect).must_include ':title=>"InSpec Example Profile"'
      _(runner.report.inspect).must_include ':status=>"passed"'
    end

    it "loads a json report twice" do
      skip "this doesn't work yet, but I'd like to poke at it"

      o = { "reporter" => ["json"], "report" => true }
      runner = ::Inspec::Runner.new(o)
      runner.add_target(example_profile)
      runner.run
      _(runner.report.count).must_equal 4
      _(runner.report.inspect).must_include ':title=>"InSpec Example Profile"'
      _(runner.report.inspect).must_include ':status=>"passed"'
    end

    # Due to the way we require/use rspec, you can only run one runner.
    # You have to reload rspec to run another.
  end
end
