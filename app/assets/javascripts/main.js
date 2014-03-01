$(document).on("page:change", function() {

  // Place JavaScript code here...
  $('a[rel=external]').attr('target', '_blank');

  $('a[disabled]').click(function(e) {
    e.preventDefault() // Prevent disabled links from being clicked
  });

  // Linked Accounts are sortable
  // http://farhadi.ir/projects/html5sortable/
  $('.linked-accounts').sortable().bind('sortupdate', function() {
    var sort_path = $(this).data('sort-path');

    var account_ids = [];
    $(this).find('[data-account-id]')
      .each(function() {
        var account_id = $(this).data('account-id');
        account_ids.push(account_id);
      });
    $.post(sort_path, { account_ids: account_ids });
  });;

});
