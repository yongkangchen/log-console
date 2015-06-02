disposable = null
doActive=->
  if atom.project.getPaths().length > 0
    disposable.dispose() if disposable
    disposable = null
    
    pkg = require "./log-console"
    pkg.activate()
  else
    disposable = atom.project.onDidChangePaths doActive

module.exports =
  activate: (state) ->
    doActive()