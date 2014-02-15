
Given /^I am at the (.+) page$/ do |page|
  visit page_path(page)
end

