module ActiveAd::Facebook::Requestable
  private

  def api_error_message(response)
    response.body.dig('error', 'message')
  end
end
