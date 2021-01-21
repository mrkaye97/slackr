
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Project Status: Active - The project has reached a stable, usable
state and is being actively
developed.](http://www.repostatus.org/badges/0.1.0/active.svg)](http://www.repostatus.org/#active)
![downloads](http://cranlogs.r-pkg.org/badges/grand-total/slackr)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/slackr)](http://cran.r-project.org/package=slackr)

![Logo](https://raw.githubusercontent.com/mrkaye97/slackr/master/slackr.png)

`slackr` - a package to send messages to Slack channels and users

The `slackr` package contains functions that make it possible to
interact with the Slack messaging platform. When you need to share
information/data from R, rather than resort to copy/paste in e-mails or
other services like Skype, you can use this package to send
well-formatted output from multiple R objects and expressions to all
teammates at the same time with little effort. You can also send images
from the current graphics device, R objects (as R data files), and
upload files.

# BREAKING CHANGES

Version 2.0.0+ is updated to work with the new Slack API structure\!

# Installation

``` r
# CRAN version
install.packages("slackr")

# Development version
devtools::install_github("mrkaye97/slackr")
```

# Setup

There are two ways of interfacing with `slackr` currently, that provide
significantly different functionality.

1.  Using only a webook to send messages to a channel (i.e. creating a
    single-channel bot)
2.  Creating a bot user to send messages to multiple channels, including
    plots, tables, files, etc. as well as deleting messages, reading the
    channels in a workspace, etc. (i.e. creating a fully-functional
    multi-channel bot)

In most cases, we recommend `Option 1` above. This requires the fewest
permissions and is the simplest to set up, and will allow basic
messaging to a specific channel.

### Webhook Bot Setup

Setting up the single-channel bot is simple.

1.  Go to <https://api.slack.com/apps>
2.  Click “Create New App”
3.  Click “Incoming Webhooks” under “Features”
4.  Turn the “Activate Incoming Webhooks” switch on
5.  Click “Add New Webhook to Workspace”
6.  Select the channel you’d like the bot to post to
7.  Copy the Webhook URL
8.  Call `slackr_setup(channel = '#channel_with_webhook',
    incoming_webhook_url = 'your_webhook')`. You can also follow the
    config file setup directions below instead of passing the channel
    and webhook directly.

And that’s it\! You should be able to post a message with
`slackr_bot('test message')`

### Multi-Functional Bot Setup

Setting up the multi-functional bot is slightly more complex than the
single-channel one.

1.  Go to <https://api.slack.com/apps>
2.  Click “Create New App”
3.  Click “OAuth & Permissions” under “Features”
4.  Enable the following scopes in order to get all of the
    functionality:

<!-- end list -->

  - `channels:read`
  - `users:read`
  - `files:read`
  - `groups:read`
  - `groups:write`
  - `chat:write`
  - `chat:write.customize`
  - `chat:write.public`
  - `im:write`
  - `incoming-webhook`
  - `channels:history`

<!-- end list -->

5.  Click “Install to Workspace”
6.  Select a channel (for webhook messages)
7.  Copy the Bot User OAuth Access Token
8.  Click “Incoming Webhooks” under “Features”
9.  Copy the Webhook URL
10. Call

<!-- end list -->

    slackr_setup(channel = '#channel_with_webhook', 
                 bot_user_oauth_token = 'your_token', 
                 incoming_webhook_url = 'your_webhook')

You can also follow the config file setup directions below instead of
passing the channel, token, and webhook directly.

And that’s it\! Once `slackr_setup()` has been run, you should be able
to post a message with `slackr('test message')`

### Config File Setup

The `slackr_setup()` function will try to read setup values from a
`~/.slackr` (you can change the default) configuration file, which may
be easier and more secure than passing them in manually (plus, will
allow you to have multiple slackr configs for multiple Slack.com teams).
The file is in Debian Control File (DCF) format since it really doesn’t
need to be JSON and R has a handy `read.dcf()` function since that’s
what `DESCRIPTION` files are coded in. Here’s the basic format for the
configuration file:

    bot_user_oauth_token: Your app's bot user OAuth token
    channel: #general
    username: slackr
    incoming_webhook_url: https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX

You can also change the default emoji icon (from the one you setup at
integration creation time) with `icon_emoji`.

### Scopes

Without all of the scopes enabled, only certain functions will work.
Which ones depends on which scopes you have enabled. See the function
documentation for which scopes are needed.

### Known Issues

  - Depending on your scopes, `slackr` could quietly fail (i.e. not
    throw an error, but also not post anything to your channel). If this
    happens, try explicitly adding the `slackr` app to your channel in
    your Slack workspace with `/invite @your_app_name`

### LaTeX for `tex_slackr`

The new function `tex_slackr` in versions `2.0.0+` requires package
[`texPreview`](https://github.com/yonicd/texPreview) which is
lazy-loaded when the former is called.

For setting up LaTeX see [`texPreview`’s System
Requirements](https://github.com/yonicd/texPreview#functionality), and
for specific OS setup check out its Github Actions like [this MacOS
example](https://github.com/yonicd/texPreview/blob/master/.github/workflows/R-mac.yml#L46).

# Usage

``` r
library(slackr)

# current verison
packageVersion("slackr")
#> [1] '2.0.3'
```

``` r
slackr_setup(channel="#channel", 
             incoming_webhook_url="https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX",
             bot_user_oauth_token='token')

slackr(str(iris))

# send images
library(ggplot2)
qplot(mpg, wt, data=mtcars)
slackr_dev("#results")

barplot(VADeaths)
slackr_dev("@jayjacobs")

ggslackr(qplot(mpg, wt, data=mtcars))
```

# Onexit Usage

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

# Test Results

``` r
library(slackr)
library(testthat)

slackr_setup(config_file = ".slackr")
#> [1] "Successfully connected to Slack"

date()
#> [1] "Wed Jan 20 17:53:25 2021"

devtools::test()
#> Loading slackr
#> Testing slackr
#> ✓ |  OK F W S | Context
#> ⠏ |   0       | connection                                                                                              ⠋ |   1       | connection                                                                                              ✓ |   4       | connection [0.2 s]
#> <e2><a0><8f> |   0       | posting                                                                                                 <e2><a0><8b> |   1       | posting                                                                                                 <e2><a0><99> |   2       | posting                                                                                                 <e2><a0><b9> |   3       | posting
#> ⠸ |   4       | posting                                                                                                 ⠼ |   5       | posting                                                                                                 ⠴ |   6       | posting                                                                                                 ⠦ |   7       | posting                                                                                                 ⠧ |   8       | posting                                                                                                 ⠇ |   9       | posting                                                                                                 ✓ |   9       | posting [5.9 s]
#> 
#> ══ Results ═════════════════════════════════════════════════════════════════════════════════════════════════════════════
#> Duration: 6.1 s
#> 
#> [ FAIL 0 | WARN 0 | SKIP 0 | PASS 13 ]
```

Many thanks to:

  - [Jay Jacobs](https://github.com/jayjacobs)
  - [David Severski](https://github.com/davidski)
  - [Quinn Weber](https://github.com/qsweber)
  - [Konrad Karczewski](https://github.com/konradjk)
  - [Ed Niles](https://github.com/eniles)
  - [Rick Saporta](https://github.com/rsaporta)
  - [Jonathan Sidi](https://github.com/yonicd)
  - [Matt Kaye](https://github.com/mrkaye97)
  - [Xinye Li](https://github.com/xinye1)
  - [Andrie de Vries](https://github.com/andrie)

for their contributions to the package\!
