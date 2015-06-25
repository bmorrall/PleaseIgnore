# Silence Cache logs
Rails.cache.silence! unless Rails.env.development?
