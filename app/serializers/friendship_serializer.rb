class FriendshipSerializer < ActiveModel::Serializer
  attributes Friendship.attribute_names

  has_one :target
  has_many :tags
end
