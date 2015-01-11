# Versions Helper
# Allows for decorating of PaperTrail::Version objects using draper
module VersionsHelper
  def decorate_version(version_model, &block)
    item_type = version_model.item_type
    decorator_class = "Versions::#{item_type}Decorator".safe_constantize

    puts decorator_class

    if decorator_class
      decorated_model = decorator_class.new(version_model)
      yield(decorated_model) if block_given?
      decorated_model
    else
      # Fall back to generic decorator
      decorate version_model, &block
    end
  end
end
