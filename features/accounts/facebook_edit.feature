Feature: Managing linked Facebook accounts
  As a registered user of the website
  I want to manage my connected Facebook accounts
  So I can control access to my Facebook accounts

  Scenario: Linking my profile with a new Facebook account
    Given I am logged in
    When I link my profile to my Facebook account
    Then I should see a successful Facebook authentication message
    And I should be linked to my Facebook account

  Scenario: Linking my profile with a previously linked Facebook account
    Given A user is already linked to my Facebook account
    And I am logged in
    When I link my profile to my Facebook account
    Then I should see a failed Facebook authentication message
    And I should not be linked to a Facebook account

  Scenario: Unlinking a previously linked Facebook account
    Given I exist as a user linked to my Facebook account
    And I am logged in
    When I unlink my Facebook account
    Then I should see a Facebook successfully unlinked message
    And I should not be linked to a Facebook account
