$ ->
  $(document).on 'click', '.versions-list a', (e)->
    e.preventDefault()
    $(this).find('.collapse').collapse('toggle')
