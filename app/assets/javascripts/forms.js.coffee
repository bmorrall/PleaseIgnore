$ ->
  $(document).on 'submit', 'form', (e)->
    @ladda.stop() if @ladda # Stop the previous spinner

    button = $(this).find('[type=submit]');
    if button.length
      # Display button with spinner
      button.attr('data-style', "expand-right").addClass('ladda-button');
      @ladda = Ladda.create(button[0]);
      @ladda.start()

  # Add Loading Indicator to Account buttons
  $(document).on 'click', '.account-buttons a, .connect-account a', (e)->
    @ladda.stop() if @ladda # Stop the previous spinner
    # Display button with spinner
    $(this).attr('data-style', "zoom-out").addClass('ladda-button');
    @ladda = Ladda.create(this);
    @ladda.start()
