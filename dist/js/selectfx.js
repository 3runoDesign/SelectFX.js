/*selectfx.js v1.0.0 - Improve the style of your selection. Based on from SelectInspiration - https://github.com/codrops/SelectInspiration
    Copyright (c) 2014 Mibuz Team <contato@mibuz.com.br> - http://mibuz.com.br
    License: MIT*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

(function(window, document) {
  'use strict';
  var BaseModules, SelectFx;
  BaseModules = (function() {
    var addClass, capitaliseString, classReg, extendObjs, fireEvent, hasClass, hasParent, isMobile, removeClass, toggleClass;

    function BaseModules() {}

    fireEvent = function(obj, evt) {
      var evObj, fireOnThis;
      fireOnThis = obj;
      if (document.createEvent) {
        evObj = document.createEvent("MouseEvents");
        evObj.initEvent(evt, true, false);
        return fireOnThis.dispatchEvent(evObj);
      } else if (document.createEventObject) {
        evObj = document.createEventObject();
        return fireOnThis.fireEvent("on" + evt, evObj);
      }
    };

    capitaliseString = function(string) {
      return string.charAt(0).toUpperCase() + string.slice(1).toLowerCase();
    };

    classReg = function(className) {
      return new RegExp("(^|\\s+)" + className + "(\\s+|$)");
    };

    hasClass = function(elem, c) {
      return elem.className.indexOf(c) !== -1;
    };

    addClass = function(elem, c) {
      return elem.className = "" + elem.className + " " + c;
    };

    removeClass = function(elem, c) {
      return elem.className = elem.className.replace(classReg(c), '');
    };

    toggleClass = function(elem, c) {
      var fn;
      fn = (hasClass(elem, c) ? removeClass : addClass);
      return fn(elem, c);
    };

    extendObjs = function(obj1, obj2) {
      var e, p;
      for (p in obj2) {
        try {
          if (obj2[p].constructor === Object) {
            obj1[p] = extendObjs(obj1[p], obj2[p]);
          } else {
            obj1[p] = obj2[p];
          }
        } catch (_error) {
          e = _error;
          obj1[p] = obj2[p];
        }
      }
      return obj1;
    };

    hasParent = function(e, p) {
      var el;
      if (!e) {
        return false;
      }
      el = e.target || e.srcElement || e || false;
      while (el && el !== p) {
        el = el.parentNode || false;
      }
      return el !== false;
    };

    isMobile = function() {
      return navigator.userAgent.match(/Android|BlackBerry|iPhone|iPad|iPod|Opera Mini|IEMobile/i);
    };

    BaseModules.prototype.has = hasClass;

    BaseModules.prototype.add = addClass;

    BaseModules.prototype.remove = removeClass;

    BaseModules.prototype.toggle = toggleClass;

    BaseModules.prototype.extend = extendObjs;

    BaseModules.prototype.hasParent = hasParent;

    BaseModules.prototype.isMobile = isMobile;

    BaseModules.prototype.fireEvent = fireEvent;

    BaseModules.prototype.capitalise = capitaliseString;

    return BaseModules;

  })();
  SelectFx = (function(_super) {
    __extends(SelectFx, _super);

    SelectFx.options = {
      onMobile: true,
      classes: {
        baseClass: "sfx-select",
        styleClass: "sfx-default",
        selectedClass: "sfx-selected",
        placeholderClass: "sfx-placeholder",
        optgroupClass: "sfx-optgroup",
        optionsClass: "sfx-options",
        focusClass: "sfx-focus",
        activeClass: "sfx-active",
        mobileClass: "sfx-mobile"
      },
      onChange: function(val) {
        return false;
      }
    };

    SelectFx.newTab = true;

    SelectFx.stickyPlaceholder = true;

    function SelectFx(el, options) {
      options = this.extend(this.constructor.options, options);
      this.el = el;
      this.options = options;
      this._init();
    }

    SelectFx.prototype._init = function() {
      var selectedOpt;
      selectedOpt = this.el.querySelector("option[selected]");
      this.hasDefaultPlaceholder = selectedOpt && selectedOpt.disabled;
      this.selectedOpt = selectedOpt || this.el.querySelector("option");
      this._createSelectEl();
      this.selOpts = [].slice.call(this.selEl.querySelectorAll("li[data-option]"));
      this.selOptsCount = this.selOpts.length;
      this.current = this.selOpts.indexOf(this.selEl.querySelector("." + this.options.classes.selectedClass)) || -1;
      this.selPlaceholder = this.selEl.querySelector("." + this.options.classes.placeholderClass);
      return this._initEvents();
    };

    SelectFx.prototype._createSelectEl = function() {
      var classMobile, createOptionHTML, options, opts_el, self;
      self = this;
      options = "";
      createOptionHTML = function(el) {
        var classes, link, optclass;
        optclass = "";
        classes = "";
        link = "";
        if ((self.selectedOpt.value === el.value) && !self.foundSelected && !self.hasDefaultPlaceholder) {
          classes += "" + self.options.classes.selectedClass + " ";
          self.foundSelected = true;
        }
        if (el.getAttribute("data-class")) {
          classes += el.getAttribute("data-class");
        }
        if (el.getAttribute("data-link")) {
          link = "data-link=" + el.getAttribute("data-link");
        }
        if (classes !== "") {
          optclass = "class=\"" + classes + "\" ";
        }
        if (el.value !== '' && el.text === '') {
          return "<li " + optclass + link + " data-option data-value=\"" + el.value + "\"><span>" + el.value + "</span></li>";
        } else {
          return "<li " + optclass + link + " data-option data-value=\"" + el.value + "\"><span>" + el.textContent + "</span></li>";
        }
      };
      [].slice.call(this.el.children).forEach(function(el) {
        var tag;
        if (el.disabled) {
          return;
        }
        tag = el.tagName.toLowerCase();
        if (tag === "option" && el.value !== '') {
          return options += createOptionHTML(el);
        } else if (tag === "optgroup") {
          options += ("<li data-optgroup class=\"" + self.options.classes.optgroupClass + "\"><span class=\"" + self.options.classes.optgroupClass + "-title\">") + el.label + "</span><ul>";
          [].slice.call(el.children).forEach(function(opt) {
            if (opt.value !== '') {
              return options += createOptionHTML(opt);
            }
          });
          return options += "</ul></li>";
        }
      });
      classMobile = this.isMobile() && this.options.onMobile ? this.options.mobileClass : '';
      opts_el = ("<div class=\"" + this.options.classes.optionsClass + "\"><ul>") + options + "</ul></div>";
      this.selEl = document.createElement("div");
      this.selEl.className = "" + this.options.classes.baseClass + " " + this.options.classes.styleClass;
      this.selEl.tabIndex = this.el.tabIndex;
      this.selEl.id = "select" + (this.capitalise(this.el.getAttribute('id')));
      this.selEl.innerHTML = ("<span class=\"" + this.options.classes.placeholderClass + "\"> <dl><dt>") + this.selectedOpt.textContent + "</dl></dt></span>" + opts_el;
      this.el.parentNode.appendChild(this.selEl);
      return this.selEl.appendChild(this.el);
    };

    SelectFx.prototype._initEvents = function() {
      var self;
      self = this;
      if (this.el.labels[0]) {
        this.el.labels[0].addEventListener("click", function() {
          self.fireEvent(self.selPlaceholder, 'click');
          return event.stopPropagation();
        });
      }
      this.selPlaceholder.addEventListener("click", function() {
        return self._toggleSelect();
      });
      this.selOpts.forEach(function(opt, idx) {
        return opt.addEventListener("click", function() {
          self.current = idx;
          self._changeOption();
          return self._toggleSelect();
        });
      });
      document.addEventListener("click", function(ev) {
        var target;
        target = ev.target;
        if (self._isOpen() && target !== self.selEl && !self.hasParent(target, self.selEl)) {
          return self._toggleSelect();
        }
      });
      return this.selEl.addEventListener("keydown", function(ev) {
        var keyCode;
        keyCode = ev.keyCode || ev.which;
        switch (keyCode) {
          case 38:
            ev.preventDefault();
            return self._navigateOpts("prev");
          case 40:
            ev.preventDefault();
            return self._navigateOpts("next");
          case 32:
            ev.preventDefault();
            if (self._isOpen() && typeof self.preSelCurrent !== "undefined" && self.preSelCurrent !== -1) {
              self._changeOption();
            }
            return self._toggleSelect();
          case 13:
            ev.preventDefault();
            if (self._isOpen() && typeof self.preSelCurrent !== "undefined" && self.preSelCurrent !== -1) {
              self._changeOption();
              return self._toggleSelect();
            }
            break;
          case 27:
            ev.preventDefault();
            if (self._isOpen()) {
              return self._toggleSelect();
            }
        }
      });
    };

    SelectFx.prototype._navigateOpts = function(dir) {
      var tmpcurrent;
      if (!this._isOpen()) {
        this._toggleSelect();
      }
      tmpcurrent = (typeof this.preSelCurrent !== "undefined" && this.preSelCurrent !== -1 ? this.preSelCurrent : this.current);
      if (dir === "prev" && tmpcurrent > 0 || dir === "next" && tmpcurrent < this.selOptsCount - 1) {
        this.preSelCurrent = (dir === "next" ? tmpcurrent + 1 : tmpcurrent - 1);
        this._removeFocus();
        return this.add(this.selOpts[this.preSelCurrent], "" + this.options.classes.focusClass);
      }
    };

    SelectFx.prototype._toggleSelect = function() {
      this._removeFocus();
      if (this._isOpen()) {
        if (this.current !== -1) {
          this.selPlaceholder.querySelector("dl dt").textContent = this.selOpts[this.current].textContent;
        }
        return this.remove(this.selEl, "" + this.options.classes.activeClass);
      } else if (!this._isOpen()) {
        if (this.hasDefaultPlaceholder && this.constructor.stickyPlaceholder) {
          this.selPlaceholder.querySelector("dl dt").textContent = this.selectedOpt.textContent;
        }
        return this.add(this.selEl, "" + this.options.classes.activeClass);
      }
    };

    SelectFx.prototype._changeOption = function() {
      var oldOpt, opt;
      if (typeof this.preSelCurrent !== "undefined" && this.preSelCurrent !== -1) {
        this.current = this.preSelCurrent;
        this.preSelCurrent = -1;
      }
      opt = this.selOpts[this.current];
      this.selPlaceholder.querySelector("dl dt").textContent = opt.textContent;
      this.el.value = opt.getAttribute("data-value");
      oldOpt = this.selEl.querySelector("." + this.options.classes.selectedClass);
      if (oldOpt) {
        this.remove(oldOpt, "" + this.options.classes.selectedClass);
      }
      this.add(opt, "" + this.options.classes.selectedClass);
      if (opt.getAttribute("data-link")) {
        if (this.constructor.newTab) {
          window.open(opt.getAttribute("data-link"), "_blank");
        } else {
          window.location = opt.getAttribute("data-link");
        }
      }
      return this.options.onChange(this.el.value);
    };

    SelectFx.prototype._isOpen = function(opt) {
      return this.has(this.selEl, "" + this.options.classes.activeClass);
    };

    SelectFx.prototype._removeFocus = function(opt) {
      var focusEl;
      focusEl = this.selEl.querySelector("." + this.options.classes.focusClass);
      if (focusEl) {
        return this.remove(focusEl, "" + this.options.classes.focusClass);
      }
    };

    return SelectFx;

  })(BaseModules);
  return window.SelectFx = SelectFx;
})(window, document);