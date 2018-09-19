
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
    
  
  # Implementation
  
  
  @_fetchFileHistory: (fileName) ->
    format = ("""{"id": "%H", "authorName": "%an", "relativeDate": "%cr", "authorDate": %at, """ +
      """ "message": "%s", "body": "%b", "hash": "%h"}""").replace(/\"/g, "#/dquotes/")
    flags = " --pretty=\"format:#{format}\" --topo-order --date=local --numstat"
    
    fstats = Fs.statSync fileName
    if fstats.isDirectory() 
      directory = fileName
      fileName = "."
    else 
      directory = Path.dirname(fileName)
      fileName = Path.basename(fileName)
      
    cmd = "git log#{flags} #{fileName}"
    console.warn '$ ' + cmd if process.env.DEBUG == '1'
    return ChildProcess.execSync(cmd,  {stdio: 'pipe', cwd: directory}).toString()
    

  @_parseGitLogOutput: (output) ->
    lastCommitObject = null
    logItems = []
    logLines = output.split("\n")
    currentCommitText = null
    totalLinesAdded = 0
    totalLinesDeleted = 0
    files = []

    addLogItem = =>
      commitObj = @_parseCommitObj(currentCommitText)
      commitObj.linesAdded = totalLinesAdded
      commitObj.linesDeleted = totalLinesDeleted
      commitObj.files = files
      logItems.push commitObj
      
      totalLinesAdded = 0
      totalLinesDeleted = 0
      files = []

    for line in logLines
      if line.match /^\{\#\/dquotes\/id\#\/dquotes\/\:/  
        if currentCommitText?
          addLogItem()
        currentCommitText = line
      else if (matches = line.match(/^([\d\-]+)\s+([\d\-]+)\s+(.*)/))
        [linesAdded, linesDeleted, fileName] = matches[1..]
        linesAdded = parseInt(linesAdded)
        linesDeleted = parseInt(linesDeleted)
        totalLinesAdded += linesAdded
        totalLinesDeleted += linesDeleted
        files.push {
          name: fileName.trim()
          linesAdded: linesAdded
          linesDeleted: linesDeleted
        }
      else if line?
        currentCommitText += line
    
    if currentCommitText
      addLogItem()
    
    return logItems


  @_parseCommitObj: (line) ->

    encLine = line.replace(/\t/g, '  ') # tabs mess with JSON parse
    .replace(/\"/g, "'")           # sorry, can't parse with quotes in body or message
    .replace(/(\n|\n\r)/g, ' <br>')
    .replace(/\r/g, ' <br>')
    .replace(/\#\/dquotes\//g, '"')
    .replace(/\\/g, '\\\\')
    .replace(/[\x00-\x1F\x7F-\x9F]/g, ' ')
    try
      return JSON.parse(encLine)
    catch
      console.warn line + "\n\n"
      console.warn "failed to parse JSON #{encLine}"
      return null
      
  ###
    See nodejs Path.normalize().  This method extends Path.normalize() to add:
    - escape of space characters 
  ###
  @_escapeForCli: (filePath) ->
    escapePrefix = if process.platform == 'win32' then '^' else '\\'
    return filePath.replace(/([\s\(\)\-])/g, escapePrefix + '$1')
