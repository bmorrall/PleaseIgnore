# Provides `enable_rails_cache` which enables rails caching for the single test
module CacheMacros
  # Class Methods methods can be called directly from the class
  module ClassMethods
    def enable_rails_cache
      # http://pivotallabs.com/tdd-action-caching-in-rails-3/
      around do |example|
        store = ActionController::Base.cache_store
        ActionController::Base.cache_store = :memory_store
        silence_warnings { Object.const_set 'RAILS_CACHE', ActionController::Base.cache_store }

        example.run

        silence_warnings { Object.const_set 'RAILS_CACHE', store }
        ActionController::Base.cache_store = store
      end
      before(:each) { Rails.cache.clear }
    end
  end

  def self.included(controller_spec)
    controller_spec.extend(ClassMethods)
  end
end
