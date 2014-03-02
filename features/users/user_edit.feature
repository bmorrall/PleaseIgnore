@javascript @csrf_protection
Feature: Edit User
  As a registered user of the website
  I want to edit my user profile
  so I can change my username

    Scenario: I sign in and edit my account
      Given I am logged in
      When I edit my account details
      Then I should see an account edited message

    Scenario: I sign in and change my password
      Given I am logged in
      When I edit my password details
      Then I should see a password changed message
