# == Schema Information
#
# Table name: organisations
#
#  id         :integer          not null, primary key
#  name       :string
#  permalink  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :organisation do
    name { Faker::Company.name }
  end
end
