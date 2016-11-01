require_relative "../../test_helper"

class TestProxyApiKeyValidationDeny < Minitest::Test
  include ApiUmbrellaTests::Setup

  def setup
    setup_server
  end

  def test_no_api_key
    response = Typhoeus.get("http://127.0.0.1:9080/api/hello", self.http_options.except(:headers))
    assert_equal(403, response.code, response.body)
    assert_match("API_KEY_MISSING", response.body)
  end

  def test_empty_api_key
    response = Typhoeus.get("http://127.0.0.1:9080/api/hello", self.http_options.deep_merge({
      :headers => {
        "X-Api-Key" => "",
      },
    }))
    assert_equal(403, response.code, response.body)
    assert_match("API_KEY_MISSING", response.body)
  end

  def test_invalid_api_key
    response = Typhoeus.get("http://127.0.0.1:9080/api/hello", self.http_options.deep_merge({
      :headers => {
        "X-Api-Key" => "invalid",
      },
    }))
    assert_equal(403, response.code, response.body)
    assert_match("API_KEY_INVALID", response.body)
  end

  def test_disabled_api_key
    user = FactoryGirl.create(:api_user, :disabled_at => Time.now.utc)
    response = Typhoeus.get("http://127.0.0.1:9080/api/hello", self.http_options.deep_merge({
      :headers => {
        "X-Api-Key" => user.api_key,
      },
    }))
    assert_equal(403, response.code, response.body)
    assert_match("API_KEY_DISABLED", response.body)
  end
end