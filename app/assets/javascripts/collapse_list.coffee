$ ->
  $(document).on 'click', '.collapse-list .list-group-item', (e)->
    e.preventDefault()
    $(this).find('.collapse').collapse('toggle')
