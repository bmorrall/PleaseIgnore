Feature: Signing in with a linked GitHub account
  As a registered user of the website with a linked GitHub account
  I want to sign in with my GitHub account
  So I don't have to enter in my login credentials

  @javascript @csrf_protection
  Scenario: Logging in with a previously linked GitHub account
    Given I exist as a user linked to my GitHub account
    And I am not logged in
    When I sign in using my GitHub account
    Then I should see a successful GitHub authentication message
    And I should be signed in
