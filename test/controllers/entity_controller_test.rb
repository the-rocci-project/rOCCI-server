require 'test_helper'

class EntityControllerTest < ActionDispatch::IntegrationTest
  HelpfulTestConstants::ENTITIES.each do |entity|
    HelpfulTestConstants::ALL_FORMATS.each do |response_format|
      test "should get collection of #{entity} in #{response_format}" do
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

    test "should delete single #{entity}" do
      delete "/#{entity}/#{HelpfulTestConstants::DUMMY_ID}",
             headers: {
               HTTP_X_AUTH_TOKEN: HelpfulTestConstants::TOKEN,
               HTTP_ACCEPT: HelpfulTestConstants::DEFAULT_FORMAT
             }
      assert_response :no_content
    end

    HelpfulTestConstants::FORMATS.each do |response_format|
      test "should get single #{entity} in #{response_format}" do
        get "/#{entity}/#{HelpfulTestConstants::DUMMY_ID}",
            headers: { HTTP_X_AUTH_TOKEN: HelpfulTestConstants::TOKEN, HTTP_ACCEPT: response_format }
        assert_response :success
        assert_equal response_format, @response.content_type
      end

      test "should not update single #{entity} from #{response_format}" do
        put "/#{entity}/#{HelpfulTestConstants::DUMMY_ID}",
            headers: {
              HTTP_X_AUTH_TOKEN: HelpfulTestConstants::TOKEN,
              HTTP_ACCEPT: response_format, CONTENT_TYPE: response_format
            }
        assert_response :not_implemented
      end

      test "should not execute action on single #{entity} without action in #{response_format}" do
        post "/#{entity}/#{HelpfulTestConstants::DUMMY_ID}?action=start",
             headers: {
               HTTP_X_AUTH_TOKEN: HelpfulTestConstants::TOKEN,
               HTTP_ACCEPT: response_format, CONTENT_TYPE: response_format
             }
        assert_response :bad_request
      end

      test "should not partially update #{entity} without mixin in #{response_format}" do
        post "/#{entity}/#{HelpfulTestConstants::DUMMY_ID}",
             headers: {
               HTTP_X_AUTH_TOKEN: HelpfulTestConstants::TOKEN,
               HTTP_ACCEPT: response_format, CONTENT_TYPE: response_format
             }
        assert_response :bad_request
      end

      test "should not create #{entity} without #{entity} in #{response_format}" do
        post "/#{entity}/",
             headers: {
               HTTP_X_AUTH_TOKEN: HelpfulTestConstants::TOKEN,
               HTTP_ACCEPT: response_format, CONTENT_TYPE: response_format
             }
        assert_response :bad_request
      end
    end
  end
end
