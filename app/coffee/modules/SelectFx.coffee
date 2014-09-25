# SelectFX

class SelectFx extends BaseModules
  @options:
    onMobile:         true

    classes:
      baseClass:        "sfx-select"
      styleClass:       "sfx-default"
      selectedClass:    "sfx-selected"
      placeholderClass: "sfx-placeholder"
      optgroupClass:    "sfx-optgroup"
      optionsClass:     "sfx-options"
      focusClass:       "sfx-focus"
      activeClass:      "sfx-active"
      mobileClass:      "sfx-mobile"

    onChange: (val) ->
      false

  @newTab = true
  @stickyPlaceholder = true

  constructor: (el, options) ->
    options = @extend @constructor.options, options

    @.el = el
    @.options = options

    @_init()

  _init : ->
    selectedOpt = @.el.querySelector("option[selected]")
    @.hasDefaultPlaceholder = selectedOpt and selectedOpt.disabled

    @.selectedOpt = selectedOpt or @.el.querySelector("option")

    # create elements
    @_createSelectEl()

    # all options
    @.selOpts = [].slice.call(@.selEl.querySelectorAll("li[data-option]"))

    # total options
    @.selOptsCount = @.selOpts.length

    # current index
    @.current = @selOpts.indexOf(@.selEl.querySelector(".#{@.options.classes.selectedClass}")) or -1

    # placeholder elem
    @.selPlaceholder = @.selEl.querySelector(".#{@.options.classes.placeholderClass}")

    # init events
    @_initEvents()

  _createSelectEl : ->
    self = @
    options = ""

    createOptionHTML = (el) ->
      optclass = ""
      classes = ""
      link = ""

      if (self.selectedOpt.value is el.value) and not self.foundSelected and not self.hasDefaultPlaceholder
        classes += "#{self.options.classes.selectedClass} "
        self.foundSelected = true

      # extra classes
      classes += el.getAttribute("data-class")  if el.getAttribute("data-class")

      # link options
      link = "data-link=" + el.getAttribute("data-link")  if el.getAttribute("data-link")

      optclass = "class=\"" + classes + "\" "  if classes isnt ""

      if el.value isnt '' and el.text is ''
        "<li " + optclass + link + " data-option data-value=\"" + el.value + "\"><span>" + el.value + "</span></li>"
      else
        "<li " + optclass + link + " data-option data-value=\"" + el.value + "\"><span>" + el.textContent + "</span></li>"

    [].slice.call(@.el.children).forEach (el) ->
      return if el.disabled
      tag = el.tagName.toLowerCase()


      if tag is "option" and el.value isnt ''
        options += createOptionHTML(el)

      else if tag is "optgroup"
        options += "<li data-optgroup class=\"#{self.options.classes.optgroupClass}\"><span class=\"#{self.options.classes.optgroupClass}-title\">" + el.label + "</span><ul>"
        [].slice.call(el.children).forEach (opt) ->
          if opt.value isnt ''
            options += createOptionHTML(opt)

        options += "</ul></li>"


    classMobile = if @isMobile() and @.options.onMobile then @.options.mobileClass else ''

    opts_el = "<div class=\"#{@.options.classes.optionsClass}\"><ul>" + options + "</ul></div>"
    @.selEl = document.createElement("div")
    @.selEl.className = "#{@.options.classes.baseClass} #{@.options.classes.styleClass}"
    @.selEl.tabIndex = @.el.tabIndex
    @.selEl.id = "select#{@capitalise @.el.getAttribute('id')}"
    @.selEl.innerHTML = "<span class=\"#{@.options.classes.placeholderClass}\"> <dl><dt>" + @.selectedOpt.textContent + "</dl></dt></span>" + opts_el
    @.el.parentNode.appendChild @.selEl
    @.selEl.appendChild @.el

  _initEvents : ->
    self = @

    # Click on the label
    if @.el.labels[0]
      @.el.labels[0].addEventListener "click", ()->
        self.fireEvent self.selPlaceholder, 'click'
        event.stopPropagation()

    # open/close select
    @.selPlaceholder.addEventListener "click", ->
      self._toggleSelect()

    @.selOpts.forEach (opt, idx) ->
      opt.addEventListener "click", ->
        self.current = idx
        self._changeOption()

        # close select elem
        self._toggleSelect()

    document.addEventListener "click", (ev) ->
      target = ev.target
      self._toggleSelect()  if self._isOpen() and target isnt self.selEl and not self.hasParent(target, self.selEl)


    @.selEl.addEventListener "keydown", (ev) ->
      keyCode = ev.keyCode or ev.which
      switch keyCode

        # up key
        when 38
          ev.preventDefault()
          self._navigateOpts "prev"

        # down key
        when 40
          ev.preventDefault()
          self._navigateOpts "next"

        # space key
        when 32
          ev.preventDefault()
          self._changeOption()  if self._isOpen() and typeof self.preSelCurrent isnt "undefined" and self.preSelCurrent isnt -1
          self._toggleSelect()

        # enter key
        when 13
          ev.preventDefault()
          if self._isOpen() and typeof self.preSelCurrent isnt "undefined" and self.preSelCurrent isnt -1
            self._changeOption()
            self._toggleSelect()

        # esc key
        when 27
          ev.preventDefault()
          self._toggleSelect()  if self._isOpen()

  _navigateOpts : (dir) ->
    @_toggleSelect()  unless @_isOpen()
    tmpcurrent = (if typeof @.preSelCurrent isnt "undefined" and @.preSelCurrent isnt -1 then @.preSelCurrent else @.current)
    if dir is "prev" and tmpcurrent > 0 or dir is "next" and tmpcurrent < @.selOptsCount - 1

      # save pre selected current - if we click on option, or press enter, or press space this is going to be the index of the current option
      @.preSelCurrent = (if dir is "next" then tmpcurrent + 1 else tmpcurrent - 1)

      # remove focus class if any..
      @_removeFocus()

      # add class focus - track which option we are navigating
      @add @.selOpts[@.preSelCurrent], "#{@.options.classes.focusClass}"

  _toggleSelect : ->
    # remove focus class if any..
    @_removeFocus()
    if @_isOpen()
      # update placeholder text
      @.selPlaceholder.querySelector("dl dt").textContent = @.selOpts[@.current].textContent  if @.current isnt -1
      @remove @selEl, "#{@.options.classes.activeClass}"
    else if not @_isOpen()
      # everytime we open we wanna see the default placeholder text
      @.selPlaceholder.querySelector("dl dt").textContent = @.selectedOpt.textContent  if @.hasDefaultPlaceholder and @constructor.stickyPlaceholder
      @add @.selEl, "#{@.options.classes.activeClass}"

  _changeOption : ->
    # if pre selected current (if we navigate with the keyboard)...
    if typeof @.preSelCurrent isnt "undefined" and @.preSelCurrent isnt -1
      @.current = @.preSelCurrent
      @.preSelCurrent = -1

    # current option
    opt = @.selOpts[@.current]

    # update current selected value
    @.selPlaceholder.querySelector("dl dt").textContent = opt.textContent

    # change native select element´s value
    @.el.value = opt.getAttribute("data-value")

    # remove class cs-selected from old selected option and add it to current selected option
    oldOpt = @.selEl.querySelector(".#{@.options.classes.selectedClass}")
    @remove oldOpt, "#{@.options.classes.selectedClass}"  if oldOpt
    @add opt, "#{@.options.classes.selectedClass}"

    # if there´s a link defined
    if opt.getAttribute("data-link")

      # open in new tab?
      if @constructor.newTab
        window.open opt.getAttribute("data-link"), "_blank"
      else
        window.location = opt.getAttribute("data-link")

    # callback
    @.options.onChange @.el.value

  _isOpen : (opt) ->
    @has @.selEl, "#{@.options.classes.activeClass}"

  _removeFocus : (opt) ->
    focusEl = @.selEl.querySelector(".#{@.options.classes.focusClass}")
    @remove focusEl, "#{@.options.classes.focusClass}"  if focusEl
