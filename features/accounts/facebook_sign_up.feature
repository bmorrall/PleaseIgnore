Feature: Facebook Registration
  As a vistor to the website
  I want to sign up using my Facebook account
  So I can create a new account quickly

  Scenario: Fill in the sign up form using Facebook account details
    Given I do not exist as a user
    When I sign in using my Facebook account
    Then I should see a successful Facebook registration message
    And I should see a sign up form with my Facebook credentials
    And I should be signed out

  @javascript @csrf_protection
  Scenario: Create a new profile linked to a Facebook account
    Given I do not exist as a user
    When I sign in using my Facebook account
    And I complete the registration form
    Then I should be signed in
    And I should be linked to my Facebook account

