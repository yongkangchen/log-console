module.exports =
  activate: (state) ->
    doActive()

doActive=->
  if atom.project.getPaths().length > 0
    pkg = require "./log-console"
    pkg.activate()
  else
    atom.project.once "path-changed", doActive
