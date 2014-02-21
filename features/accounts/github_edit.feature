Feature: Managing linked GitHub accounts
  As a registered user of the website
  I want to manage my connected GitHub accounts
  So I can control access to my GitHub accounts

  Scenario: Connecting with a new GitHub account
    Given I am logged in
    When I link my profile to my GitHub account
    Then I should see a successful GitHub authentication message
    And I should be linked to my GitHub account

  Scenario: Connecting with a previously linked GitHub account
    Given A user is already linked to my GitHub account
    And I am logged in
    When I link my profile to my GitHub account
    Then I should see a failed GitHub authentication message
    And I should not be linked to a GitHub account

  Scenario: Unlinking a previously linked GitHub account
    Given I exist as a user linked to my GitHub account
    And I am logged in
    When I unlink my GitHub account
    Then I should see a GitHub successfully unlinked message
    And I should not be linked to a GitHub account

