$ ->
  $(document).on 'submit', 'form', (e)->
    @ladda.stop() if @ladda # Stop the previous spinner

    button = $(this).find('[type=submit]');
    if button.length
      button.attr('data-style', "expand-right").addClass('ladda-button');

      # Display button with spinner
      @ladda = Ladda.create(button[0]);
      @ladda.start() # Small delay to prevent jolts
