Feature: GitHub Registration
  As a visitor to the website
  I want to sign up using my GitHub account
  So I can create a new account quickly

  Scenario: Fill in the sign up form using GitHub account details
    Given I do not exist as a user
    When I sign in using my GitHub account
    Then I should see a successful GitHub registration message
    And I should see a sign up form with my GitHub credentials
    And I should be signed out

  @javascript @csrf_protection
  Scenario: Create a new profile linked to a GitHub account
    Given I do not exist as a user
    When I sign in using my GitHub account
    And I complete the registration form
    Then I should be signed in
    And I should be linked to my GitHub account

