require_relative "../../test_helper"

class TestProxyRequestRewritingPassApiKeyHeader < Minitest::Test
  include ApiUmbrellaTests::Setup
  parallelize_me!

  def setup
    setup_server
    once_per_class_setup do
      prepend_api_backends([
        {
          :frontend_host => "127.0.0.1",
          :backend_host => "127.0.0.1",
          :servers => [{ :host => "127.0.0.1", :port => 9444 }],
          :url_matches => [{ :frontend_prefix => "/#{unique_test_class_id}/pass-api-key-header/", :backend_prefix => "/" }],
          :settings => {
            :pass_api_key_header => true,
          },
        },
      ])
    end
  end

  def test_api_key_given_in_header
    assert(self.http_options[:headers]["X-Api-Key"])
    response = Typhoeus.get("http://127.0.0.1:9080/#{unique_test_class_id}/pass-api-key-header/info/", self.http_options)
    assert_equal(200, response.code, response.body)
    data = MultiJson.load(response.body)
    assert_equal(self.api_key, data["headers"]["x-api-key"])
    assert_equal({}, data["url"]["query"])
  end

  def test_api_key_given_in_query
    response = Typhoeus.get("http://127.0.0.1:9080/#{unique_test_class_id}/pass-api-key-header/info/?api_key=#{self.api_key}", self.http_options.except(:headers))
    assert_equal(200, response.code, response.body)
    data = MultiJson.load(response.body)
    assert_equal(self.api_key, data["headers"]["x-api-key"])
    assert_equal({}, data["url"]["query"])
  end

  def test_api_key_given_in_basic_auth
    response = Typhoeus.get("http://127.0.0.1:9080/#{unique_test_class_id}/pass-api-key-header/info/", self.http_options.except(:headers).deep_merge({
      :userpwd => "#{self.api_key}:",
    }))
    assert_equal(200, response.code, response.body)
    data = MultiJson.load(response.body)
    assert_equal(self.api_key, data["headers"]["x-api-key"])
    assert_equal({}, data["url"]["query"])
    refute(data["basic_auth_username"])
    refute(data["headers"]["authorization"])
  end
end