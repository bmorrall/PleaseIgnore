module ApplicationHelper

  def header_nav_class(path)
    current_page?(path) ? 'active' : nil
  end

end
