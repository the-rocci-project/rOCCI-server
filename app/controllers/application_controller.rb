class ApplicationController < ActionController::API
  include Configurable
  include Authorizable
  include Renderable
  include Errorable

  include BackendAccessible
  include ModelAccessible

  # @return [Occi::Core::Collection] initialized collection
  def empty_collection
    collection = Occi::Core::Collection.new
    collection.categories = server_model.categories
    collection
  end
end
