local spec_helper = require "spec.spec_helpers"
local http_client = require "kong.tools.http_client"

local STUB_GET_URL = spec_helper.STUB_GET_URL
local STUB_POST_URL = spec_helper.STUB_POST_URL

describe("Kong Proxy Plugin", function()

  setup(function()
    spec_helper.prepare_db()
    spec_helper.insert_fixtures {
      api = {
        {name = "mocking1", upstream_url = "http://mockbin.com", request_host="mockbin.com"},
        {name = "mocking2", upstream_url = "http://mockbin.com", request_host="mockbin2.com"},
      },
      consumer = {
      },
      plugin = {
        {
          name = "kong-proxy",
          __api = 1
        }
      }
    }

    spec_helper.start_kong()
  end)

  teardown(function()
    spec_helper.stop_kong()
  end)

  describe("Response", function()
     it("should return an Hello-World header with Hello World!!! value when say_hello is true", function()
      local _, status, headers = http_client.get(STUB_GET_URL, {}, {host = "mockbin.com", Timestamp_M = "google.com"})
      assert.are.equal(200, status)
      assert.are.same("Hello World!!!", headers["HOST"])
    end)

    it("should return an Hello-World header with Bye World!!! value when say_hello is false", function()
      local _, status, headers = http_client.get(STUB_GET_URL, {}, {host = "mockbin2.com"})
      assert.are.equal(200, status)
      assert.are.same("Bye World!!!", headers["HOST"])
    end)
  end)
end)
