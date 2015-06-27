@javascript @csrf_protection
Feature: Contact Request pre-filled with User details
  In order to give support all the information it needs
  A visitor or user starting a contact request
  Should have as much data already entered as possible

  Scenario: Begin a contact request from the Sign up page
    Given I am at the sign up page
     When I begin a new contact request
     Then I should be notified I am making a request from the sign up page

  Scenario: Begin a contact request from the Sign in page
    Given I am at the sign in page
     When I begin a new contact request
     Then I should be notified I am making a request from the sign in page

  Scenario: Begin a contact request from the Privacy Policy page
    Given I am at the privacy policy page
     When I begin a new contact request
     Then I should be notified I am making a request from the privacy policy page

  Scenario: Begin a contact request from the Terms of Service page
    Given I am at the terms of service page
     When I begin a new contact request
     Then I should be notified I am making a request from the terms of service page

