module PagesHelper

  def tos_header(header_tag, content)
    header_id = content.downcase.gsub(/\W/, '-')
    content_tag header_tag, content, id: header_id
  end

end
