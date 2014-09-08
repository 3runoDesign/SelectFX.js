/*selectfx.js v1.0.0 - Improve the style of your selection. Based on from SelectInspiration - https://github.com/codrops/SelectInspiration
    Copyright (c) 2014 Mibuz Team <contato@mibuz.com.br> - http://mibuz.com.br
    License: MIT*/

(function($) {
  if (!$) {
    return;
  }
  return $.fn.selectfx = function(option) {
    return this.each(function() {
      var $this, options;
      $this = $(this);
      options = typeof option === 'object' && option;
      options = $.extend(true, {}, SelectFx.options, options);
      return $this.each(function(el) {
        return new SelectFx(this, options);
      });
    });
  };
})(window.Zepto || window.jQuery);