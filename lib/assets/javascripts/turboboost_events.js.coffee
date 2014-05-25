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

Turboboost.defaultError = App.t('turboboost.default_errors')
Turboboost.insertErrors = false # Don't allow Turboboost to render errors

tryJSONParse = (str) ->
  try
    JSON.parse str
  catch e
    null

$(document).on "turboboost:error", (e, errors) ->
  parsed_errors = tryJSONParse(errors)
  $('[data-turboboost]').displayErrors parsed_errors, Turboboost.defaultError

$(document).on "turboboost:success", (e, flash) ->
  console.log('turboboost success')
  console.log(flash)
