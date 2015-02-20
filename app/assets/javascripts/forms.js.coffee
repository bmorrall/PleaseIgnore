$ ->
  $('form').on 'submit', (e)->
    @ladda.stop() if @ladda # Stop the previous spinner

    button = $(this).find('[type=submit]');
    button.attr('data-style', "expand-right").addClass('ladda-button');

    # Display button with spinner
    @ladda = Ladda.create(button[0]);
    @ladda.start() # Small delay to prevent jolts