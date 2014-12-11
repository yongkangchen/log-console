{$, $$, View, Point} = require 'atom'

icon_dict =
  warning: "alert"
  info: "info"
  error: "flame"

open = (href, lineNumber) ->
  atom.workspace.open(href).done ->
    return unless lineNumber >= 0
    if textEditor = atom.workspace.getActiveTextEditor()
      position = new Point(lineNumber)
      textEditor.scrollToBufferPosition(position, center: true)
      textEditor.setCursorBufferPosition(position)
      textEditor.moveToFirstCharacterOfLine()

module.exports =
class LogConsoleView extends View
  @content: ->
    @div =>
      @div class: 'log-console-resize-handle', mousedown: 'resizeStarted', dblclick: 'resizeToMin'
      @div class: 'icon-btn-xs btn-group btn-group-xs', =>
        @button class: 'btn', click: 'clear', 'Clear'
        @button class: 'btn selected', 'Collapse'
      @div class: 'pull-right icon-btn-xs btn-group btn-group-xs', outlet: 'filterGroup', click: 'filterHandler', =>
        @button class: 'btn text-highlight icon-info', '0'
        @button class: 'btn text-warning icon-alert', '0'
        @button class: 'btn text-error icon-flame', '0'
      @ul class: 'log-console list-group', outlet:'listView'

  initialize: () ->
    @listView.on 'click', 'a', (event)->
      console.error "click a:", event
      target = $(event.target).closest('a')
      href = target.attr("href")
      return unless href
      event.preventDefault()
      open(href, parseInt(target.attr("line"))-1)

    @listView.on 'click', 'li', (event)->
      target = $(event.target)
      if target.is("span")
        target = target.closest('li')
      else
        return unless target.is("li")
      target = target.find(".detail")
      return if target.html() == ""
      target.toggle()

    atom.workspaceView.appendToBottom(this)
    @resizeToMin()

  clear: ->
    @listView.find("li").remove()
    @filterGroup.children().each (i, child)->
      $(child).text("0")

  addLine: (msg, type, detail) ->
    iconCss = 'icon-'+icon_dict[type]
    element = $$ ->
      @li class: type+' icon '+iconCss+' list-item', =>
        @span =>
          @raw msg
        @div class: "detail", style:"display:none", =>
          @raw detail

    countBtn = @filterGroup.find("."+iconCss)
    if countBtn.hasClass("selected")
      display = "none"
    else
      display = "block"
    element.css("display", display)

    @listView.append element
    @listView.scrollToBottom()

    countBtn.text(parseInt(countBtn.text())+1)

  filterHandler: (event, element) ->
    target = $(event.target)
    for v in event.target.classList
      if v.startsWith("icon-")
        type = "."+v
        break

    return unless type
    if target.toggleClass("selected").hasClass("selected")
      @listView.find(type).css("display", "none")
    else
      @listView.find(type).css("display", "block")

  resizeStarted: ->
    $(document).on('mousemove', @resizeTreeView)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: ->
    $(document).off('mousemove', @resizeTreeView)
    $(document).off('mouseup', @resizeStopped)

  resizeToMin: ->
    height = 50
    @height(height)
    @listView.css("max-height", height)
    @listView.scrollToBottom()

  resizeTreeView: (e) =>
    {pageY, which} = e
    return @resizeStopped() unless which is 1
    height = $(document.body).height()-pageY

    return if height < 25

    @height(height)
    @listView.css("max-height", height)
