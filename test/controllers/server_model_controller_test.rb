require 'test_helper'

class ServerModelControllerTest < ActionDispatch::IntegrationTest
  HelpfulTestConstants::FORMATS.each do |response_format|
    test "should get model in #{response_format}" do
      get '/-/', headers: { HTTP_X_AUTH_TOKEN: HelpfulTestConstants::TOKEN, HTTP_ACCEPT: response_format }
      assert_response :success
      assert_equal response_format, @response.content_type
    end
  end
end
