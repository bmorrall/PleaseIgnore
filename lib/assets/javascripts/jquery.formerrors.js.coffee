# Boostrap Form Error Display jQuery Plugin
#
# Updates a Twitter Boostrap form with error messages and a alert message.
#
# Copyright 2014, Ben Morrall
# Released under the MIT license.

# Removes all errors from a form
jQuery.fn.clearErrors = (errors) ->
  this.find('.alert').remove()
  this.find('p.help-block').remove()
  this.find('.has-error').removeClass('has-error')
  this

# Displays error messages on a form
#
# `alert_message` is displayed in a .alert.alert-danger div at the top of the form.
#
# For each key in `errors`:
#  - it attempts to find a .form-group wrapper with the class of key,
#    - it adds has-errors class to the form-group
#    - it appends p.help-block for each message
#  - it adds message for fields that cannot be found to the .alert-danger div
#
# Error keys should include the base class in the field name (i.e. 'user_name' vs 'name').
# Simpleform can be monkey patched to display errors in the same manner.
#
# @param errors hash with error field classes with array of error messages.
# @param alert_messsage Default message to be displayed at the top of the form.
jQuery.fn.displayErrors = (errors, alert_message = '') ->
  this.clearErrors()

  # Highlight fields with errors
  base_errors = []
  for field, messages of errors
    $form_group = this.find(".form-group.#{field}")

    $form_group.addClass('has-error')

    for message in messages
      if $form_group.length
        # Append error to form group
        message_help_block = '<p class="help-block animated fadeIn">' + message + '</p>'
        $form_group.find('[class^=col-]').append message_help_block
      else
        # Add base error message to alert
        base_errors.push message

  # Display alert box
  if alert_message || base_errors.length
    this.prepend '<div class="alert alert-danger animated fadeInDown">' + alert_message + '</div>'

  # Add Base Errors to Alert
  if base_errors.length
    error_messages = '<ul><li>' + base_errors.join('</li><li>') + '</li></ul>'
    this.find('.alert-danger').append(error_messages)

  this # allow chaining
