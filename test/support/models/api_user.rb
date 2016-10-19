class ApiUser
  include Mongoid::Document
  include Mongoid::Timestamps
  field :_id, :type => String, :overwrite => true, :default => lambda { SecureRandom.uuid }
  field :api_key, :default => lambda { SecureRandom.hex(20) }
  field :first_name
  field :last_name
  field :email
  field :email_verified, :type => Boolean
  field :website
  field :use_description
  field :registration_source
  field :throttle_by_ip, :type => Boolean
  field :disabled_at, :type => Time
  field :roles, :type => Array
  field :registration_ip
  field :registration_user_agent
  field :registration_referer
  field :registration_origin
  field :created_by
  attr_accessor :terms_and_conditions
  embeds_one :settings, :class_name => "Api::Settings"

  def api_key_preview
    self.api_key.truncate(9)
  end
end