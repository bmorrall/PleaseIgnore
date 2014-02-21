Feature: Signing in with a linked Twitter account
  As a registered user of the website with a linked Twitter account
  I want to sign in with my Twitter account
  So I don't have to enter in my login credentials

  Scenario: Logging in with a previously linked Twitter account
    Given I exist as a user linked to my Twitter account
    And I am not logged in
    When I sign in using my Twitter account
    Then I should see a successful Twitter authentication message
    And I should be signed in
