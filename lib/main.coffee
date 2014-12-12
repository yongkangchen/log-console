module.exports =
  activate: (state) ->
    doActive()

doActive=->
  if atom.project.getPath()
    pkg = require "./log-console"
    pkg.activate()
  else
    atom.project.once "path-changed", doActive
