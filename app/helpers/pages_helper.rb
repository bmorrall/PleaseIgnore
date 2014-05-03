# Pages Helper
# Helper methods for Pages Controller
module PagesHelper
  # Adds a Terms of Service header with an anchor tag
  def tos_header(title, options = {})
    tag = options.delete(:tag) || :h3
    options[:id] ||= title.downcase.gsub(/\W/, '-')
    content_tag :header do
      content_tag tag, title, options
    end
  end
end
