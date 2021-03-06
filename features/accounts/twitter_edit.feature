Feature: Managing linked Twitter accounts
  As a registered user of the website
  I want to manage my connected Twitter accounts
  So I can control access to my Twitter accounts

  @javascript @csrf_protection
  Scenario: Linking my profile with a new Twitter account
    Given I am logged in
    When I link my profile to my Twitter account
    Then I should see a successful Twitter linked message
    And I should be linked to my Twitter account

  Scenario: Linking my profile with a previously linked Twitter account
    Given I am already linked to my Twitter account
    And I am logged in
    When I link my profile to my Twitter account
    Then I should see a failed Twitter authentication message
    And I should not be linked to a Twitter account

  @javascript @csrf_protection
  Scenario: Unlinking a previously linked Twitter account
    Given I exist as a user linked to my Twitter account
    And I am logged in
    When I unlink my Twitter account
    Then I should see a Twitter successfully unlinked message
    And I should not be linked to a Twitter account

