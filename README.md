
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

See the vignettes for setup instructions.

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

### Thank Yous

Many thanks to:

  - [Bob Rudis](https://github.com/hrbrmstr)
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
