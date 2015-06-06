# Displays a hash with { key => [old_value, new_value] } as a summary of changes
class DiffSummaryPresenter
  # Null Object used as a stand in for `ActiveRecord::Base#human_attribute_name`
  class HumanAttributeNameNull
    def human_attribute_name(attribute_name)
      attribute_name.to_s.titleize
    end
  end

  def self.display(h, changeset, item_klass = nil)
    new(h, changeset, item_klass).display
  end

  attr_reader :changeset
  attr_reader :h
  attr_reader :item_klass

  def initialize(h, changeset, item_klass = nil)
    @h = h
    @changeset = changeset
    @item_klass = item_klass || HumanAttributeNameNull.new
  end

  def display
    h.content_tag :table do
      sorted_changeset_values.map do |attribute, values|
        display_row_tag(attribute, values)
      end.join.html_safe
    end
  end

  protected

  def attribute_name(name)
    item_klass.human_attribute_name(name)
  end

  def attribute_value(value)
    if value.blank?
      h.content_tag :em, '(nil)'
    else
      h.h value
    end
  end

  def display_row_tag(attribute, values)
    h.content_tag :tr do
      [
        attribute_name_table_cell(attribute),
        attribute_value_table_cell(values[0]),
        h.content_tag(:th, '->'),
        attribute_value_table_cell(values[1])
      ].join.html_safe
    end
  end

  def attribute_name_table_cell(attribute)
    h.content_tag(:th, attribute_name(attribute))
  end

  def attribute_value_table_cell(value)
    h.content_tag(:td, attribute_value(value))
  end

  def sorted_changeset_values
    changeset.reject { |k, _v| k.match(/user_id/) }.sort
  end
end
