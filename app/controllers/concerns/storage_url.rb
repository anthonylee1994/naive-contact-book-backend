module StorageUrl
  extend ActiveSupport::Concern

  included do
    before_action do
      ActiveStorage::Current.url_options = { host: request.base_url }
    end
  end
end
