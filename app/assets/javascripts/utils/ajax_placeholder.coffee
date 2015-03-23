(($) ->
  # Only updates the placeholder if placeholder_src matches it's current data-placeholder-src attribute
  updatePlaceholder = ($input, placeholder_src, new_value) ->
    current_src = $input.attr('data-placeholder-src')
    if current_src == placeholder_src
      $input.attr 'placeholder', new_value
    return

  inputChanged = ->
    placeholder_path = $(this).data('placeholder-path')
    placeholder_target = $(this).data('placeholder-target')

    placeholder_src = ($(this).val() || '').substring(0, 255)

    $placeholder_target = $("input##{placeholder_target}")

    # Don't change if the string hasn't changed
    return if placeholder_src == $placeholder_target.attr('data-placeholder-src')

    # Store the value as a safety check
    $placeholder_target.attr('data-placeholder-src', placeholder_src)

    if placeholder_src.length == 0 || ($placeholder_target.val() || '').length
      # Do empty values manually
      updatePlaceholder($placeholder_target, '', '')

    $.ajax(
      url: placeholder_path,
      context: $placeholder_target,
      data: { value: placeholder_src },
      dataType: 'json',
      success: (data, _textStatus, _jqXHR) ->
        updatePlaceholder $(this), placeholder_src, data.result
    )
    return

  $(document).on 'input',
                 'input[data-placeholder-path][data-placeholder-target]',
                 $.throttle( 500, inputChanged )
  return
)(jQuery)
