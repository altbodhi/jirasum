# Package

version       = "0.1.0"
author        = "Anonymous"
description   = "get summary news from jira for some days"
license       = "MIT"
srcDir        = "src"
bin           = @["jirasum"]
skipDirs      = @["public"]

# Dependencies

requires "nim >= 1.0.0"
requires "jester"
requires "templates"
