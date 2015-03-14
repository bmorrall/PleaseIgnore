# Turboboost Events
#
# Added callbacks for Turboboost to behave correctly for a Twitter Boostrap based site.
#
# DEPENDENCIES:
#   - jquery
#   - jquery.formerrors
#   - translations
#
# Copyright 2014, Ben Morrall
# Released under the MIT license.

DEFAULT_ERROR = I18n.t('turboboost.default_errors')
UNKNOWN_ERROR = I18n.t('turboboost.unknown_error')

Turboboost.insertErrors = false # Don't allow Turboboost to render errors

tryJSONParse = (str) ->
  try
    JSON.parse str
  catch e
    null

$(document).on 'ajax:beforeSend', ->
  # Create a Ladda button
  button = $('[data-turboboost] [type=submit]');
  button.attr('data-style', "expand-right").addClass('ladda-button');

  @ladda.stop() if @ladda # Stop the previous spinner

  # Display button with spinner
  @ladda = Ladda.create(button[0]);
  @ladda.startAfter(200) # Small delay to prevent jolts

$(document).on "turboboost:error", (e, errors) ->
  parsed_errors = tryJSONParse(errors)
  error_message = (if parsed_errors then DEFAULT_ERROR else UNKNOWN_ERROR) ||
    Turboboost.defaultError
  $('[data-turboboost]').displayErrors parsed_errors, error_message

$(document).on "turboboost:success", (e, flash) ->
  console.log('turboboost success')
  console.log(flash)

$(document).on "turboboost:complete", (e) ->
  @ladda.stop() if @ladda # Stop the Ladda spinner
