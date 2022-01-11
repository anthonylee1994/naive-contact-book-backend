module AsContact
  extend ActiveSupport::Concern

  included do
    has_many :user_contacts, dependent: :destroy
  end
end
