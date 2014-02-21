$(document).on("page:change", function() {

  // Place JavaScript code here...
  $('a[rel=external]').attr('target', '_blank');

  $('a[disabled]').click(function(e) {
    e.preventDefault() // Prevent disabled links from being clicked
  });

});
