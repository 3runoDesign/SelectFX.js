(($)->
  return unless $

  $.fn.selectfx = (option)->
    @each ->
      $this = $(@)
      options = typeof option is 'object' and option
      options = $.extend true, {}, SelectFx.options, options

      $this.each (el)->
        new SelectFx(@, options)

) window.Zepto or window.jQuery
