require 'test_helper'

class MixinControllerTest < ActionDispatch::IntegrationTest
  test 'should not create mixin' do
    post '/-/',
         headers: {
           HTTP_X_AUTH_TOKEN: HelpfulTestConstants::TOKEN,
           HTTP_ACCEPT: HelpfulTestConstants::DEFAULT_FORMAT,
           CONTENT_TYPE: HelpfulTestConstants::DEFAULT_FORMAT
         }
    assert_response :not_implemented
  end

  test 'should not delete mixin' do
    delete '/-/',
           headers: {
             HTTP_X_AUTH_TOKEN: HelpfulTestConstants::TOKEN,
             HTTP_ACCEPT: HelpfulTestConstants::DEFAULT_FORMAT
           }
    assert_response :not_implemented
  end
end
