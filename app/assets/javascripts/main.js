
$(document).ready(function() {

  $(document).pjax('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax]):not([rel])', '[data-pjax-container]')

})

$(document).on("pjax:start", function() {

  // Remove the currently active menu item
  $('[role=nav] li.active').removeClass('active');

});

$(document).on("ready pjax:end", function() {

  // Make external links open in a new window
  $('a[rel=external]').attr('target', '_blank');

  // Prevent disabled links from being clicked
  $('a[disabled]').click(function(e) {
    e.preventDefault();
  });

});
