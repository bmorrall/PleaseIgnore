Feature: Google Registration
  As a vistor to the website
  I want to sign up using my Google account
  So I can create a new account quickly

  Scenario: Fill in the sign up form using Google account details
    Given I do not exist as a user
    When I sign in using my Google account
    Then I should see a successful Google registration message
    And I should see a sign up form with my Google credentials
    And I should be signed out

  @javascript @csrf_protection
  Scenario: Create a new profile linked to a Google account
    Given I do not exist as a user
    When I sign in using my Google account
    And I sign up with valid user data
    Then I should be signed in
    And I should be linked to my Google account

