@javascript @csrf_protection
Feature: Password Reset
  In order to recover from a lost password
  A user
  Should be able to reset my password

    Background:
      Given I am not logged in

    Scenario: User requests password reset
      Given I exist as a user
      When I enter a valid password reset request
      Then I should see a password reset email has been sent notice
      And I should receive an email with Reset password instructions

    Scenario: User requests password reset without an account
      Given I do not exist as a user
      When I enter a valid password reset request
      Then I should see a password reset email has been sent notice
      And I should have no emails

    Scenario: User resets their password with valid details
      Given I exist as a user
      And I have made a password reset request
      When I open and click the first link in the email
      And I enter valid password reset details
      Then I should see a password was reset message
      And I should be signed in

    Scenario: User resets their password with invalid details
      Given I exist as a user
      And I have made a password reset request
      When I open and click the first link in the email
      And I enter mismatched password reset confirmation
      Then I should see a missing password confirmation message