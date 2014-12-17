# log-console package [![Make a donation via Paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=lx1988cyk%40gmail%2ecom&lc=US&no_note=0&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHostedGuest)

a IDE like console for atom.

# Features
* tail a log file
* parse log type of `Info`、`Warning`、`Error`
* filter log by type
* support log block
* support jump to file

![log-console](https://cloud.githubusercontent.com/assets/704762/5394431/5354b19e-8178-11e4-883c-bb4b22b6b245.png)

# Usage
Create file .log-console.json in your project root with these settings:
* `logfile` — the log file path
* `blockSep` — the log block seperator
* `logTypePattern` — a regex pattern to parse log type
* `logTypeDict` — log type dict
* `fileAndLinePattern` — a regex pattern to parse file path and line number

# Example of Unity3D
```
{
  "logfile": "/Users/xxoo/Library/Logs/Unity/Editor.log",
  "blockSep": "\n\n",
  "logTypePattern": "UnityEngine\\.Debug:Log(.*)\\(Object\\)",
  "fileAndLinePattern": "\\(at (.*):(\\d+)\\)",
  "logTypeDict":{
    "": "info",
    "Error": "error",
    "Warning": "warning"
  }
}
```
