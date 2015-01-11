$ ->
  $('.versions-list a').click (e)->
    e.preventDefault()
    $(this).find('.collapse').collapse('toggle')
