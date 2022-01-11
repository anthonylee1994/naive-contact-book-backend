class ApplicationController < ActionController::API
  include WithAuthorization
  include WithStorageUrl
end
