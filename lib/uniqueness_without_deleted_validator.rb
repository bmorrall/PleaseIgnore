# https://github.com/radar/paranoia/issues/31#issuecomment-38649182
class UniquenessWithoutDeletedValidator < ActiveRecord::Validations::UniquenessValidator
  protected

  def build_relation(klass, table, attribute, value) #:nodoc:
    super.and(table[klass.paranoia_column].eq(nil))
  end
end
