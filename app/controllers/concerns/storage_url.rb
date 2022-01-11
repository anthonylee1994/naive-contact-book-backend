module StorageUrl
  extend ActiveSupport::Concern

  included do
    before_action :set_active_storage_base_url
  end

  def set_active_storage_base_url
    ActiveStorage::Current.url_options = { host: request.base_url }
  end
end
