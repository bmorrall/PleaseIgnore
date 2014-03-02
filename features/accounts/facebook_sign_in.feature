Feature: Signing in with a linked Facebook account
  As a registered user of the website with a linked Facebook account
  I want to sign in with my Facebook account
  So I don't have to enter in my login credentials

  @javascript @csrf_protection
  Scenario: Logging in with a previously linked Facebook account
    Given I exist as a user linked to my Facebook account
    And I am not logged in
    When I sign in using my Facebook account
    Then I should see a successful Facebook authentication message
    And I should be signed in
