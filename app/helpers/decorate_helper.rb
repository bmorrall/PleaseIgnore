# Decorator Helper
# Allows for decorating of models using draper
module DecorateHelper

  # Decorates a model using the decorate function
  # Can accept a block which yields the decorated model as a param.
  def decorate(model)
    decorated_model = model.decorate
    yield(decorated_model) if block_given?
    decorated_model
  end

  # Decorates an array uning an instance of `decorator_class`
  # Can accept a block which yields the decorated model as a param.
  def decorate_collection(collection, decorator_class)
    decorated_collection = decorator_class.decorate_collection(collection)
    yield(decorated_collection) if block_given?
    decorated_collection
  end
end