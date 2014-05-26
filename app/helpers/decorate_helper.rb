# Decorator Helper
# Allows for decorating of models using draper
module DecorateHelper
  # Decorates a model using the decorate function
  # Can accept a block which yields the decorated model as a param.
  #
  # @param model [Object] object to be wrapped with a decorator
  # @yield [decorated_model] yields a block with the decorated model
  # @return the decorated model
  def decorate(model)
    decorated_model = model.decorate
    yield(decorated_model) if block_given?
    decorated_model
  end

  # Decorates an array uning an instance of `decorator_class`
  # Can accept a block which yields the decorated model as a param.
  #
  # @param collection [Array] Array of Objets to be decorated
  # @param decorator_class [Object] Draper class used to decorate each collection item
  # @yield [decorated_collection] yields a array of decorated collection items
  # @return a array with each item decorated
  def decorate_collection(collection, decorator_class)
    decorated_collection = decorator_class.decorate_collection(collection)
    yield(decorated_collection) if block_given?
    decorated_collection
  end
end
