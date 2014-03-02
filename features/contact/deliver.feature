@javascript
Feature: User sends contact reqeust
  In order to notify support
  A user
  Should be able to send a contact request

  @csrf_protection
  Scenario: User sends a contact request to support
    Given I am at the home page
     When I send a contact request
     Then I should see a thank you message
     And "support@pleaseignore.com" should receive an email

  @csrf_protection
  Scenario: User attempts to send a contact request with errors
    Given I am at the home page
    When I submit an incomplete contact request
    Then I see an invalid contact request message
    And "support@pleaseignore.com" should receive no emails

