# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# include non-CDN jQuery in compiled assets
Rails.application.config.assets.precompile += %w(jquery/dist/jquery.js)

# include Bower components in compiled assets
Rails.application.config.assets.append_path 'components'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

# Explicitly add required files into assets
Rails.application.config.assets.precompile.push(proc do |path|
  [
    %r{\Afont-awesome\/fonts}, # include font-awesome fonts
  ].any? { |pattern| path =~ pattern }
end)
