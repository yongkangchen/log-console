path = require "path"
fs = require "fs"

{Tail} = require 'tail'

LogConsoleView = require './log-console-view'

SETTINGS_FILE_NAME = ".log-console.json"

module.exports = LogConsole =
  logConsoleView: null
  tail: null
  logTypePattern: null
  fileAndLinePattern: null

  activate: (state) ->
    @logConsoleView = new LogConsoleView()

    # TODO: This gets the path of the first project path, which may not be the
    #       actual current project (if there are multiple project roots)
    @configPath = path.join atom.project.getPaths()[0], SETTINGS_FILE_NAME
    fs.exists @configPath, (exists)=>
      if exists
        @load()
      else
        @logConsoleView.addLine "Couldn't find config: .log-console.json", "error"

    # TODO: Use disposable instead?
    atom.commands.add "atom-workspace", "log-console:reload-config", =>
      @load()

  deactivate: ->
    @logConsoleView.remove()
    @tail.unwatch() if @tail
    @tail = null

  serialize: ->
    logConsoleViewState: @logConsoleView.serialize()

  toggle: ->
    console.log 'LogConsole was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

  load: ->
    fs.readFile @configPath, "utf8", (err, data) =>
      return @logConsoleView.addLine "Load log-console config error: " + err, "error" if err

      try
        @logConfig = JSON.parse(data)
      catch err
        return @logConsoleView.addLine "load #{@configPath}, #{err}", "error"

      if typeof(@logConfig.logTypePattern) == "string"
        @logConfig.logTypePattern = [@logConfig.logTypePattern]

      if typeof(@logConfig.fileAndLinePattern) == "string"
        @logConfig.fileAndLinePattern = {"": @logConfig.fileAndLinePattern}


      @logTypePattern = for v in @logConfig.logTypePattern
        new RegExp(v)

      @fileAndLinePattern = {}
      for k, v of @logConfig.fileAndLinePattern
        @fileAndLinePattern[k] = new RegExp(v)

      @tail.unwatch() if @tail
      # TODO: 1. Allow paths to be relative to project root
      #       2. Create an error if the file does not exist
      #          (currently throws an error from tail)
      @tail = new Tail @logConfig.logfile, @logConfig.blockSep

      @tail.on "line", (data)=>
        @addBlock(data)

      @tail.on "error", (error)->
        console.error error

  formatLine: (line)->
    for k,v of @fileAndLinePattern
      tag = line.match(v)
      if tag
        tag[1] = k + tag[1]
        idx = line.indexOf(tag[0])

        line = line.substr(0, idx) + "<a href='#{tag[1]}' line='#{tag[2]}'>#{tag[0]}</a>" + line.substr(idx+tag[0].length)
        break
    return line

  addBlock: (data) ->
    for v in @logTypePattern
      type = data.match(v)
      break if type

    if not type
      console.error "unkown type:", JSON.stringify(data)
      return

    type = @logConfig.logTypeDict[type[1]]

    data = data.split("\n")
    msg = data.shift()
    data.pop() if data[data.length-1] == ""

    data = for line in data
      line = @formatLine(line)
      "<p>#{line}</p>"
    @logConsoleView.addLine @formatLine(msg), type, data.join("\n")
