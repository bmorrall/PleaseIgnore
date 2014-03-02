/*
 * JS Module and Plugin Initalisation Scripts for PleaseIgnore
 *
 * Depends on Turbolinks for ready/page change event.
 *
 * DEPENDENCIES:
 *   - jquery
 *   - jquery_ujs
 *   - users.js
 *
 * @author Ben Morrall <bemo56@hotmail.com>
 */

/*jslint browser: true*/
/*global jQuery*/
(function ($) {
  "use strict";

  var PleaseIgnore = window.PleaseIgnore || (window.PleaseIgnore = {});

  // Update content on Turbolinks ready/change event
  $(document).on("page:change", function () {

    // Open External links in a new browser window
    $('a[rel=external]').attr('target', '_blank');

    // Prevent disabled links from being clicked
    $('a[disabled]').click(function (e) {
      e.preventDefault();
    });

    // Refresh CSRF Tokens
    $.rails.refreshCSRFTokens();

    // Users
    PleaseIgnore.Users.initSortableAccounts();

  });

}(jQuery));
