Feature: Signing in with a linked Google account
  As a registered user of the website with a linked Google account
  I want to sign in with my Google account
  So I don't have to enter in my login credentials

  Scenario: Logging in with a previously linked Google account
    Given I exist as a user linked to my Google account
    And I am not logged in
    When I sign in using my Google account
    Then I should see a successful Google authentication message
    And I should be signed in
