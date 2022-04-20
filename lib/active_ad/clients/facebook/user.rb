class ActiveAd::Facebook::User < ActiveAd::Base
  # Reference: [https://developers.facebook.com/docs/graph-api/reference/user/]

  # The public_profile permission allows apps to read the following fields: id, first_name, last_name, middle_name, name, name_format, picture & short_name.
  READ_FIELDS = %i[
    id about age_range birthday cover currency devices education email favorite_athletes favorite_teams first_name gender hometown inspirational_people
    installed is_guest_user languages last_name link locale location middle_name name name_format payment_pricepoints picture political quotes
    relationship_status religion short_name significant_other supports_donate_button_in_live_video third_party_id timezone token_for_business verified
    video_upload_limits website work
  ].freeze

  has_many :businesses

  attribute :id, :big_integer
  attribute :about, :string
  attribute :age_range
  attribute :birthday, :string
  attribute :context
  attribute :cover
  attribute :currency
  attribute :devices, array: true
  attribute :education, array: true
  attribute :email, :string
  attribute :favorite_athletes, array: true
  attribute :favorite_teams, array: true
  attribute :first_name, :string
  attribute :gender, :string
  attribute :hometown
  attribute :inspirational_people, array: true
  attribute :installed, :boolean
  attribute :is_guest_user, :boolean
  attribute :is_verified, :boolean
  attribute :languages, array: true
  attribute :last_name, :string
  attribute :link, :string
  attribute :locale, :string
  attribute :location
  attribute :middle_name, :string
  attribute :name, :string
  attribute :name_format, :string
  attribute :payment_pricepoints
  attribute :picture
  attribute :political, :string
  attribute :quotes, :string
  attribute :relationship_status, :string
  attribute :religion, :string
  attribute :short_name, :string
  attribute :significant_other
  attribute :supports_donate_button_in_live_video, :boolean
  attribute :third_party_id, :big_integer
  attribute :timezone, :integer
  attribute :token_for_business, :string
  attribute :verified, :string
  attribute :video_upload_limits
  attribute :website, :string
  attribute :work, array: true

  def read_request(**kwargs)
    params = kwargs.dup
    fields = ((params.delete(:fields) || READ_FIELDS) + relational_attributes).uniq

    {
      get: "#{client.base_url}/me",
      params: params.merge(access_token: client.access_token, fields: fields.join(','))
    }
  end

  private

  # Attributes to be requested from the external API which are required by `belongs_to` to work.
  def relational_attributes
    %i[]
  end
end
