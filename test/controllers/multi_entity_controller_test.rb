require 'test_helper'

class MultiEntityControllerTest < ActionDispatch::IntegrationTest
  HelpfulTestConstants::MULTI_ENTITIES.each do |entity|
    HelpfulTestConstants::ALL_FORMATS.each do |response_format|
      test "should get collection of abstract #{entity} in #{response_format}" do
        get "/#{entity}/", headers: { HTTP_X_AUTH_TOKEN: HelpfulTestConstants::TOKEN, HTTP_ACCEPT: response_format }
        assert_response :success
        assert_equal response_format, @response.content_type
      end
    end

    test "should delete collection of #{entity}" do
      delete "/#{entity}/",
             headers: {
               HTTP_X_AUTH_TOKEN: HelpfulTestConstants::TOKEN,
               HTTP_ACCEPT: HelpfulTestConstants::DEFAULT_FORMAT
             }
      assert_response :success
    end

    HelpfulTestConstants::FORMATS.each do |response_format|
      test "should not create abstract #{entity} from #{response_format}" do
        post "/#{entity}/",
             headers: {
               HTTP_X_AUTH_TOKEN: HelpfulTestConstants::TOKEN,
               HTTP_ACCEPT: response_format, CONTENT_TYPE: response_format
             }
        assert_response :not_implemented
      end
    end
  end
end
