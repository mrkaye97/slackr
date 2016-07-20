## Test environments

* local OS X install, R 3.3.1
* win-builder (devel and release)
* ubuntu 14.04 R 3.3.1

## R CMD check results

There were no ERRORs or WARNINGs. 

## IMPORTANT BUG FIX

The Slack API changed and returns extra info that causes 90% of the functions
in this package to break (it introduces a duplicate column name that caused 
major problems for dplyr functions). 