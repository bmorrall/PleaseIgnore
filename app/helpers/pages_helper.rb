# Pages Helper
# Helper methods for Pages Controller
module PagesHelper
  # Adds a Terms of Service header with an anchor tag
  #
  # @param title [String] Display title of the header
  # @param options [Hash] tag and id options for the header
  # @return header for tos element
  def tos_header(title, options = {})
    tag = options.delete(:tag) || :h3
    options[:id] ||= title.downcase.gsub(/\W/, '-')
    content_tag :header do
      content_tag tag, title, options
    end
  end
end
