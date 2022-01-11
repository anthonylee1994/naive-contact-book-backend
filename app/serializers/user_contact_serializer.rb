class UserContactSerializer < ActiveModel::Serializer
  attributes UserContact.attribute_names

  has_one :contact
end
