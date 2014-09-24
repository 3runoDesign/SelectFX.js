  # Helper functions
  # App.has( elem, 'my-class' ) -> true/false
  # App.add( elem, 'my-new-class' )
  # App.remove( elem, 'my-unwanted-class' )
  # App.toggle( elem, 'my-class' )
  #
  # App.extend (ObjectDefault, ObjectSetting) -> ObjectCustom
  # App.isMobile() -> true/false
  # App.hasParent(elem, parent) -> true/false


class BaseModules
  # based on from http://www.cristinawithout.com/content/function-trigger-events-javascript
  fireEvent = (obj, evt) ->
    fireOnThis = obj
    if document.createEvent
      evObj = document.createEvent("MouseEvents")
      evObj.initEvent evt, true, false
      fireOnThis.dispatchEvent evObj
    else if document.createEventObject #IE
      evObj = document.createEventObject()
      fireOnThis.fireEvent "on" + evt, evObj

  capitaliseString = (string) ->
    string.charAt(0).toUpperCase() + string.slice(1).toLowerCase()

  classReg = (className) ->
    new RegExp("(^|\\s+)" + className + "(\\s+|$)")

  hasClass = (elem, c) ->
    elem.className.indexOf(c) isnt -1

  addClass = (elem, c) ->
    elem.className = "#{elem.className} #{c}"

  removeClass = (elem, c) ->
    elem.className = elem.className.replace classReg(c), ''

  toggleClass = (elem, c)->
    fn = (if hasClass(elem, c) then removeClass else addClass)
    fn elem, c

  # Based on from http://api.jquery.com/jquery.extend/
  extendObjs = (obj1, obj2) ->
    for p of obj2
      try

        # Property in destination object set; update its value.
        if obj2[p].constructor is Object
          obj1[p] = extendObjs(obj1[p], obj2[p])
        else
          obj1[p] = obj2[p]
      catch e

        # Property in destination object not set; create it and set its value.
        obj1[p] = obj2[p]
    obj1

  # based on from https://github.com/inuyaksa/jquery.nicescroll/blob/master/jquery.nicescroll.js
  hasParent = (e, p) ->
    return false unless e

    el = e.target or e.srcElement or e or false
    el = el.parentNode or false  while el and el isnt p
    el isnt false

  isMobile = ->
    navigator.userAgent.match(/Android|BlackBerry|iPhone|iPad|iPod|Opera Mini|IEMobile/i)

  has: hasClass
  add: addClass
  remove: removeClass
  toggle: toggleClass

  extend: extendObjs
  hasParent: hasParent
  isMobile: isMobile
  fireEvent: fireEvent
  capitalise: capitaliseString
