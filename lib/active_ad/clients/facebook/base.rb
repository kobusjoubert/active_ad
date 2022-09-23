class ActiveAd::Facebook::Base < ActiveAd::Base
  def api_error_message(response)
    response.body.dig('error', 'message')
  end
end
