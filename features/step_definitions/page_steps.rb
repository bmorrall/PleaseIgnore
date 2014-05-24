
Given(/^I am at (.+)$/) do |page|
  visit path_to(page)
end
