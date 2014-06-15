/*
 * User pages scripts for PleaseIgnore
 *
 * Depends on external scripts to bind to events
 *
 * DEPENDENCIES:
 *   - jquery
 *   - jquery.sortable
 *
 * @author Ben Morrall <bemo56@hotmail.com>
 */

/*jslint browser: true*/
/*global jQuery*/
var PleaseIgnore = window.PleaseIgnore || (window.PleaseIgnore = {});

PleaseIgnore.Users = (function ($) {
  "use strict";

  return {
    /**
     * Drag and Drop sorting for User Accounts
     *
     * Useage:
     *   Requires a .linked-accounts[data-sort-path] containing children with [data-account-id]
     *
     * see: http://farhadi.ir/projects/html5sortable/
     */
    initSortableAccounts: function () {
      $('.linked-accounts[data-sort-path]').sortable().bind('sortupdate', function () {
        var sort_path = $(this).data('sort-path');

        var account_ids = [];
        $(this).find('[data-account-id]')
          .each(function() {
            var account_id = $(this).data('account-id');
            account_ids.push(account_id);
          });
        $.post(sort_path, { account_ids: account_ids });
      });
    }
  };
}(jQuery));
