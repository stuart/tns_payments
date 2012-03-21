module TNSPayments
  class Response
    
    attr_reader :raw_response

    def initialize response
      @raw_response = response
    end

    def response
      @response ||= JSON.parse(raw_response)
    end

    def success?
      %w[SUCCESS OPERATING].include? response['result'] || response['status']
    end

    def message
      result = response['response'].fetch('result') { 'SUCCESS' }
      if result == 'ERROR'
        response['response']['error']['explanation']
      else
        'Successful request'
      end
    end
    
    # 3D Secure
    def gateway_code
      response['response']['3DSecure']['gatewayCode']
    end
    
    def enrolled?
      gateway_code == 'CARD_ENROLLED'
    end
    
    def authenticated?
       gateway_code == 'AUTHENTICATION_SUCCESSFUL'
    end
    
    def customized?
      response['3DSecure']['authenticationRedirect']['customized']
    end
    
    def acs_url
      response['3DSecure']['authenticationRedirect']['customized']['acsUrl'] if customized?
    end
    
    def pa_req
      response['3DSecure']['authenticationRedirect']['customized']['paReq'] if customized?
    end
    
    def html_body_content
      response['3DSecure']['authenticationRedirect']['simple']['htmlBodyContent'] unless customized?
    end
  end
end
