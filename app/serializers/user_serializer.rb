class UserSerializer < ActiveModel::Serializer
  attributes User.attribute_names - %w[secret] + %w[avatar_url]

  attribute :secret, if: -> { @instance_options[:show_secret] }

  def avatar_url
    object.avatar.url
  end
end
