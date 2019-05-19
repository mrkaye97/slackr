
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Build
Status](https://travis-ci.com/bestdan/slackr.svg?branch=master)](https://travis-ci.com/bestdan/slackr)

-----

**Forked Version** : This is a forked version of hrbrmstr’s
[slackr](https://github.com/hrbrmstr/slackr) package.

-----

<img src="slackr.png" width="200px" />

`slackr` - a package to send user messages & webhook API messages to
Slack channels/users

The `slackr` package contains functions that make it possible to
interact with the Slack messaging platform. When you need to share
information/data from R, rather than resort to copy/paste in e-mails or
other services like Skype, you can use this package to send
well-formatted output from multiple R objects and expressions to all
teammates at the same time with little effort. You can also send images
from the current graphics device, R objects (as R data files), and
upload files.

## News and breaking changes

[Look here](NEWS.md)

### SETUP

The `slackr_setup()` function will try to read setup values from a
`~/.slackr` (you can change the default) configuration file, which may
be easier and more secure than passing them in manually (plus, will
allow you to have multiple slackr configs for multiple Slack.com teams).
The file is in Debian Control File (DCF) format since it really doesn’t
need to be JSON and R has a handy `read.dcf()` function since that’s
what `DESCRIPTION` files are coded in. Here’s the basic format for the
configuration file:

    api_token: YOUR_FULL_API_TOKEN
    channel: #general
    username: slackr
    incoming_webhook_url: https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX

You can also change the default emoji icon (from the one you setup at
integration creation time) with `icon_emoji`.

### Installation

``` r
devtools::install_github("bestdan/slackr")
```

### Usage

``` r
library(slackr)
#> Registered S3 methods overwritten by 'ggplot2':
#>   method         from 
#>   [.quosures     rlang
#>   c.quosures     rlang
#>   print.quosures rlang

# current verison
packageVersion("slackr")
#> [1] '1.6.0'
```

``` r
slackrSetup(channel="#code", 
            incoming_webhook_url="https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX")

slackr(str(iris))

# send images
library(ggplot2)
qplot(mpg, wt, data=mtcars)
dev.slackr("#results")

barplot(VADeaths)
dev.slackr("#general")

ggslackr(qplot(mpg, wt, data=mtcars))
```

### Test Results

``` r
library(slackr)
library(testthat)

date()
#> [1] "Sun May 19 10:08:50 2019"

test_dir("tests/")
#> ✔ |  OK F W S | Context
#> ── 1. Error: (unknown) (@test-1start.R#1)  ──────────────────────────────────────────────────────────────────────────
#> cannot open the connection
#> 1: source("helpers/helper_loadCredentials.R") at testthat/test-1start.R:1
#> 2: file(filename, "r", encoding = encoding)
#> 
#> ── 2. Error: Webhook fails/works appropriately (@test-slackr.R#6)  ──────────────────────────────────────────────────
#> object 'creds' not found
#> 1: slackr_setup(channel = "#publicchanneltest", incoming_webhook_url = creds$incoming_webhook_url, username = "slackr_bot") at testthat/test-slackr.R:6
#> 2: Sys.setenv(SLACK_INCOMING_URL_PREFIX = incoming_webhook_url) at /Users/danielegan/src/slackr/R/slackr_setup.r:73
#> 
#> ── 3. Error: Valid api tokens work (@test-slackr.R#25)  ─────────────────────────────────────────────────────────────
#> object 'creds' not found
#> 1: slackr_setup(channel = "#publicchanneltest", api_token = creds$slack_bot$valid$api_token, username = "slackr_bot", icon_emoji = "thumbsup") at testthat/test-slackr.R:25
#> 2: Sys.setenv(SLACK_API_TOKEN = api_token) at /Users/danielegan/src/slackr/R/slackr_setup.r:74
#> 
#> ══ testthat results  ════════════════════════════════════════════════════════════════════════════════════════════════
#> OK: 0 SKIPPED: 1 WARNINGS: 1 FAILED: 3
#> 1. Error: (unknown) (@test-1start.R#1) 
#> 2. Error: Webhook fails/works appropriately (@test-slackr.R#6) 
#> 3. Error: Valid api tokens work (@test-slackr.R#25) 
#> 
#> ── 4. Error: (unknown) (@test-all.R#2)  ─────────────────────────────────────────────────────────────────────────────
#> testthat unit tests failed
#> 1: test_check("slackr") at tests//test-all.R:2
#> 2: test_package_dir(package = package, test_path = test_path, filter = filter, reporter = reporter, ..., stop_on_failure = stop_on_failure, 
#>        stop_on_warning = stop_on_warning, wrap = wrap)
#> 3: test_dir(path = test_path, reporter = reporter, env = env, filter = filter, ..., stop_on_failure = stop_on_failure, stop_on_warning = stop_on_warning, 
#>        wrap = wrap)
#> 4: test_files(paths, reporter = reporter, env = env, stop_on_failure = stop_on_failure, stop_on_warning = stop_on_warning, 
#>        wrap = wrap)
#> 5: with_reporter(reporter = current_reporter, results <- lapply(paths, test_file, env = env, reporter = current_reporter, 
#>        start_end_reporter = FALSE, load_helpers = FALSE, wrap = wrap))
#> 6: reporter$end_reporter()
#> 7: stop("testthat unit tests failed", call. = FALSE)
#> 
#> 
✔ |   0       |  [0.1 s]
#> 
#> ══ Results ══════════════════════════════════════════════════════════════════════════════════════════════════════════
#> Duration: 0.2 s
#> 
#> OK:       0
#> Failed:   0
#> Warnings: 0
#> Skipped:  0
```

### Onexit Usage

``` r
 ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
 trt <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
 group <- gl(2, 10, 20, labels = c("Ctl","Trt"))
 weight <- c(ctl, trt)

 #pass a message to Slack channel 'general'
 register_onexit(lm,'bazinga!',channel="#general")

 lm.D9 <- slack_lm(weight ~ group)

 #test that output keeps inheritance
 summary(lm.D9)

 #pass a message to Slack channel 'general' with a header message to begin output
 register_onexit(lm,'bazinga!',
 channel="#general",
 header_msg='This is a message to begin')

 lm.D9 <- slack_lm(weight ~ group)

 #onexit with an expression that calls lm.plot
 register_onexit(lm,{
  par(mfrow = c(2, 2), oma = c(0, 0, 2, 0))
  plot(z) #z is the internal output of stats::lm()
 },
 channel="#general",
 header_msg = 'This is a plot just for this output',
 use_device = TRUE)

 lm.D9 <- slack_lm(weight ~ group)

#clean up slack channel from examples
delete_slackr(count = 6,channel = '#general')
```
