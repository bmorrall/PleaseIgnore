Feature: Contact Support Email
  In order to be notified of any errors
  PleaseIgnore Support
  Should have received an email with all information

  Scenario: Received contact request sent from the Home page
    Given A visitor has sent a contact request from the home page
     When "support@pleaseignore.com" opens the email
     Then I should see the full contact request message
      And I should see it was sent from the home page

  Scenario: Received contact request sent from the Sign up page
    Given A visitor has sent a contact request from the sign up page
     When "support@pleaseignore.com" opens the email
     Then I should see the full contact request message
      And I should see it was sent from the sign up page

  Scenario: Received contact request sent from the Sign in page
    Given A visitor has sent a contact request from the sign in page
     When "support@pleaseignore.com" opens the email
     Then I should see the full contact request message
      And I should see it was sent from the sign in page

  Scenario: Received contact request sent from the Privacy Policy page
    Given A visitor has sent a contact request from the privacy policy page
     When "support@pleaseignore.com" opens the email
     Then I should see the full contact request message
      And I should see it was sent from the privacy policy page

  Scenario: Received contact request sent from the Terms of Service page
    Given A visitor has sent a contact request from the terms of service page
     When "support@pleaseignore.com" opens the email
     Then I should see the full contact request message
      And I should see it was sent from the terms of service page

