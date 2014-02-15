Feature: User Contact Reqeusts
  In order to contact support
  A user
  Should be able to send a contact request

    Scenario: User is stuck on the home page
      Given I am at the home page
       When I send a contact request
       Then I should see a thank you message
        And "support@pleaseignore.com" should receive an email

