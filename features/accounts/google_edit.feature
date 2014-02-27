Feature: Managing linked Google accounts
  As a registered user of the website
  I want to manage my connected Google accounts
  So I can control access to my Google accounts

  Scenario: Linking my profile with a new Google account
    Given I am logged in
    When I link my profile to my Google account
    Then I should see a successful Google authentication message
    And I should be linked to my Google account

  Scenario: Linking my profile with a previously linked Google account
    Given A user is already linked to my Google account
    And I am logged in
    When I link my profile to my Google account
    Then I should see a failed Google authentication message
    And I should not be linked to a Google account

  Scenario: Unlinking a previously linked Google account
    Given I exist as a user linked to my Google account
    And I am logged in
    When I unlink my Google account
    Then I should see a Google successfully unlinked message
    And I should not be linked to a Google account