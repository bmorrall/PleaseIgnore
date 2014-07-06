Feature: Developer Auth Integration
  As a developer
  In order to ensure that omniauth works
  I should be to test account linking using a Developer auth provider

  Scenario: User attempts to register with Developer account
    Given I am not logged in
    When I sign in using a Developer account
    Then I should see a successful Developer registration message
    And I should see a sign up form with my Developer credentials

  Scenario: User attempts to sign in with a prevously linked Developer auth account
    Given I am already linked to my Developer account
    And I am not logged in
    When I sign in using a Developer account
    Then I should see a failed Developer sign in message
    And I should be signed out

  Scenario: User connects with Developer auth while signed in
    Given I am logged in
    When I sign in using a Developer account
    Then I should see a successful Developer linked message
    And I should be linked to my Developer account

