
ChildProcess = require "child_process"
Path = require "path"
Fs = require "fs"

_ = require('underscore')


module.exports = class GitLogUtils


  ###
    returns an array of javascript objects representing the commits that effected the requested file
    with line stats, that looks like this:
      [{
        "id": "1c41d8f647f7ad30749edcd0a554bd94e301c651",
        "authorName": "Bee Wilkerson",
        "relativeDate": "6 days ago",
        "authorDate": 1450881433,
        "message": "docs all work again after refactoring to bumble-build",
        "body": "",
        "hash": "1c41d8f",
        "linesAdded": 2,
        "linesDeleted": 2
      }, {
        ...
      }]
  ###

  @getCommitHistory: (fileName)->
    logItems = []
    lastCommitObj = null
    rawLog = @_fetchFileHistory(fileName)
    return @_parseGitLogOutput(rawLog)

  @isGit: (directory) ->
    try
      return ChildProcess.execSync('git rev-parse --is-inside-work-tree', {stdio: 'pipe', cwd: directory}) and true
    catch error
      return false
      # if error.status is 128
      #   return false
      # else
      #   throw error

  @isHg: (directory) ->
    try
      return ChildProcess.execSync('hg root', {stdio: 'pipe', cwd: directory}) and true
    catch error
      # Not sure how to check if this is a 'not in HG' error
      return false

  # Implementation
  @_fetchHgFileHistoryCmd: (fileName) ->
    format = ("""\\{"id": "{node}", "authorName": "{author|person}", "relativeDate": "{date|age}", """ +
      """ "authorDate": "{date(date, '%s')}", "message": "{desc|firstline}", """ +
      """ "body": "{sub(r'^.*\\n?\\n?', '', desc)}", "hash": "{node|short}",""" +
      """ "linesModified": "{diffstat}"\}\n""").replace(/\"/g, "#/dquotes/")

    flags = "--template \"#{format}\""
    return "hg log #{flags} #{fileName}"

  @_fetchGitFileHistoryCmd: (fileName) ->
    format = ("""{"id": "%H", "authorName": "%an", "relativeDate": "%cr", "authorDate": %at, """ +
      """ "message": "%s", "body": "%b", "hash": "%h"}""").replace(/\"/g, "#/dquotes/")
    flags = " --pretty=\"format:#{format}\" --topo-order --date=local --numstat"

    return "git log#{flags} #{fileName}"

  @_fetchFileHistory: (fileName) ->
    fstats = Fs.statSync fileName
    if fstats.isDirectory()
      directory = fileName
      fileName = ""
    else
      directory = Path.dirname(fileName)

    fileName = Path.normalize(@_escapeForCli(fileName))

    cmd = null
    if @isGit(directory)
      cmd = @_fetchGitFileHistoryCmd(fileName)
    else if @isHg(directory)
      cmd = @_fetchHgFileHistoryCmd(fileName)
    else
      throw "Not a GIT or MERCURIAL directory #{directory}"

    console.log '$ ' + cmd if process.env.DEBUG == '1'

    return ChildProcess.execSync(cmd,  {stdio: 'pipe', cwd: directory}).toString()

  @_parseGitLogOutput: (output) ->
    lastCommitObject = null
    logItems = []
    logLines = output.split("\n")
    for line in logLines
      if line[0] == '{' && line[line.length-1] == '}'
        lastCommitObj = @_parseCommitObj(line)
        logItems.push lastCommitObj if lastCommitObj
      else if line[0] == '{'
        # this will happen when there are newlines in the commit message
        lastCommitObj = line
      else if _.isString(lastCommitObj)
        lastCommitObj += line
        if line[line.length-1] == '}'
          lastCommitObj = @_parseCommitObj(lastCommitObj)
          logItems.push lastCommitObj if lastCommitObj
      else if lastCommitObj? && (matches = line.match(/^(\d+)\s*(\d+).*/))
        # console.log "lastCommitObj", lastCommitObj
        # git log --num-stat appends line stats on separate lines
        lastCommitObj.linesAdded = (lastCommitObj.linesAdded || 0) + Number.parseInt(matches[1])
        lastCommitObj.linesDeleted = (lastCommitObj.linesDeleted || 0) + Number.parseInt(matches[2])

      if lastCommitObj and typeof lastCommitObj.linesModified is 'string'
        [_modified, _added_deleted] = lastCommitObj.linesModified.split(':')
        [_added, _deleted] = _added_deleted.split('/')
        lastCommitObj.linesAdded = Number.parseInt(_added)
        lastCommitObj.linesDeleted = Number.parseInt(_deleted) * -1
        delete lastCommitObj.linesModified

    return logItems

  @_parseCommitObj: (line) ->
    encLine = line.replace(/\t/g, '  ') # tabs mess with JSON parse
    .replace(/\"/g, "'")           # sorry, can't parse with quotes in body or message
    .replace(/(\n|\n\r)/g, '<br>')
    .replace(/\r/g, '<br>')
    .replace(/\#\/dquotes\//g, '"')
    try
      return JSON.parse(encLine)
    catch
      console.warn "failed to parse JSON #{encLine}"
      return null

  ###
    See nodejs Path.normalize().  This method extends Path.normalize() to add:
    - escape of space characters
  ###
  @_escapeForCli: (filePath) ->
    escapePrefix = if process.platform == 'win32' then '^' else '\\'
    return filePath.replace(/([\s\(\)\-])/g, escapePrefix + '$1')
