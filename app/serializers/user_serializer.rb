class UserSerializer < ActiveModel::Serializer
  attributes User.attribute_names - %w[secret otp_secret_key] + %w[avatar_url]

  attribute :secret, if: -> { @instance_options[:show_secret] }
  attribute :otp_code, if: -> { @instance_options[:show_secret] }

  has_many :user_contacts

  def avatar_url
    object.avatar.url
  end

  def otp_code
    object.otp_code(time: Time.now + 3600)
  end
end
