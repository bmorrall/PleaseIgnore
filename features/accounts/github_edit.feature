Feature: Managing linked GitHub accounts
  As a registered user of the website
  I want to manage my connected GitHub accounts
  So I can control access to my GitHub accounts

  @javascript @csrf_protection
  Scenario: Connecting with a new GitHub account
    Given I am logged in
    When I link my profile to my GitHub account
    Then I should see a successful GitHub linked message
    And I should be linked to my GitHub account

  Scenario: Connecting with a previously linked GitHub account
    Given I am already linked to my GitHub account
    And I am logged in
    When I link my profile to my GitHub account
    Then I should see a failed GitHub authentication message
    And I should not be linked to a GitHub account

  @javascript @csrf_protection
  Scenario: Unlinking a previously linked GitHub account
    Given I exist as a user linked to my GitHub account
    And I am logged in
    When I unlink my GitHub account
    Then I should see a GitHub successfully unlinked message
    And I should not be linked to a GitHub account

