require 'helper'

class TNSPayments::ResponseTest < MiniTest::Unit::TestCase
  def test_success_when_operating
    assert Response.new({:result => 'OPERATING'}.to_json).success?
  end

  def test_success_when_success
    assert Response.new({:result => 'SUCCESS'}.to_json).success?
  end

  def test_success_when_not_successful
    refute Response.new({:result => '404 RESOURCE NOT FOUND'}.to_json).success?
  end

  def test_message_when_error_request
    response = "{\"result\":\"401 UNAUTHORIZED\",\"response\":{\"error\":{\"cause\":\"INVALID_REQUEST\",\"explanation\":\"Invalid credentials.\"},\"result\":\"ERROR\"}}"
    assert_equal 'Invalid credentials.', Response.new(response).message
  end

  def test_message_when_success_request
    assert_equal 'Successful request', Response.new({:result => 'SUCCESS', :response => {}}.to_json).message
  end

  def test_raw_response_is_the_json
    response = "{\"result\":\"401 UNAUTHORIZED\",\"response\":{\"error\":{\"cause\":\"INVALID_REQUEST\",\"explanation\":\"Invalid credentials.\"},\"result\":\"ERROR\"}}"
    assert_equal response, Response.new(response).raw_response
  end
  
  def test_authentication_successful
    assert Response.new({:response => {:"3DSecure" => {:gatewayCode => "AUTHENTICATION_SUCCESSFUL"}}}.to_json).authenticated?
  end
  
  def test_authentication_failed
    refute Response.new({:response => {:"3DSecure" => {:gatewayCode => "AUTHENTICATION_FAILED"}}}.to_json).authenticated?
  end
  
  def test_enrolled
    assert Response.new({:response => {:"3DSecure" => {:gatewayCode => "CARD_ENROLLED"}}}.to_json).enrolled?
  end
  
  def test_not_enrolled
    refute Response.new({:response => {:"3DSecure" => {:gatewayCode => "CARD_NOT_ENROLLED"}}}.to_json).enrolled?
  end
  
  def test_acs_url
    assert_equal 'http://acs_url', Response.new({:"3DSecure" => {:authenticationRedirect => {:customized => {:acsUrl => 'http://acs_url'}}}}.to_json).acs_url
  end
  
  def test_acs_url_returns_nil_when_simple
    assert_nil Response.new({:"3DSecure" => {:authenticationRedirect => {:simple => {:htmlBodyContent => '<html></html>'}}}}.to_json).acs_url
  end
  
  def test_pa_req
    assert_equal '12345XRSR', Response.new({:"3DSecure" => {:authenticationRedirect => {:customized => {:paReq => '12345XRSR'}}}}.to_json).pa_req
  end
end
