# Displays a hash with { key => [old_value, new_value] } as a summary of changes
class DiffSummaryPresenter
  def self.display(h, changeset)
    new(h, changeset).display
  end

  attr_reader :changeset
  attr_reader :h

  def initialize(h, changeset)
    @h = h
    @changeset = changeset
  end

  def display
    [
      '---',
      change_summary_attributes
    ].join("\n").html_safe
  end

  protected

  def change_summary_attributes
    changeset.sort.map do |attribute, values|
      h.content_tag(:strong, attribute) +
        ': ' +
        attribute_value(values[0]) +
        ' -> ' +
        attribute_value(values[1])
    end.join("\n").html_safe
  end

  def attribute_value(value)
    if value.nil?
      h.content_tag :em, '(nil)'
    elsif value == ''
      h.content_tag :em, '(blank)'
    else
      h.h value
    end
  end
end
