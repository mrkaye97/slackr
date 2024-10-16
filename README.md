
<!-- README.md is generated from README.Rmd. Please edit that file -->

# slackr <a href="https://matthewrkaye.com/slackr"><img src="man/figures/logo.png" align="right" height="138" alt = ""/></a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/slackr)](https://CRAN.R-project.org/package=slackr)
[![R-CMD-check](https://github.com/mrkaye97/slackr/workflows/R-CMD-check/badge.svg)](https://github.com/mrkaye97/slackr/actions)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![](https://cranlogs.r-pkg.org/badges/slackr)](https://cran.r-project.org/package=slackr)
[![codecov](https://codecov.io/gh/mrkaye97/slackr/branch/master/graph/badge.svg?token=5HjUtFfIJR)](https://codecov.io/gh/mrkaye97/slackr)
<!-- badges: end -->

`slackr` provides a set of tools for making it easier to send messages,
data, alerts, etc. directly from R to Slack. You can use this package to
send well-formatted output from R to all teammates (or to specific
individuals) at the same time with little effort. You can send text, R
function output, images from the current graphics device and `ggplots`,
R objects (as R data files), rendered LaTeX expressions, and uploaded
files.

## Installation

``` r
# CRAN version
install.packages("slackr")

# Development version
devtools::install_github("mrkaye97/slackr")
```

## Breaking Changes

Version `3.0.0+` removes all references to `bot_user_oauth_token`
(deprecated in `v2.4.0`) in favor of `token`. There have also been
significant changes to how `slackr` and `slackr_bot` handle errors. See
[the changelog](https://matthewrkaye.com/slackr/news/index.html) for
more details.

Version `2.4.0+` now allows users to choose between using a bot token
and a user token. See below for details and check the changelog
(`NEWS.md`) for more changes.

## Setup

There are three ways of interfacing with `slackr` that provide
significantly different functionality:

1.  Creating a single-channel bot

    Using only a webhook to send messages to a channel

2.  Creating a fully-functional multi-channel bot

    Creating a bot user to send messages to multiple channels, including
    plots, tables, files, etc. as well as deleting messages, reading the
    channels in a workspace, etc.

3.  Using a user token to send messages from a specific user’s account

    Similar to the fully-scoped bot token, but connected to the account
    of a single user. This approach is not recommended in production
    settings – or any settings where a token needs to be shared – but it
    can be useful for one-off Slack messages as it lets users send data
    as themselves as opposed to through a bot.

In most cases, we recommend `Option 1` above. This requires the fewest
permissions and is the simplest to set up, and will allow basic
messaging to a specific channel.

See the vignettes for setup instructions.

## Vignettes

The vignettes contain setup instructions and example usage:

- Option 1 setup: `vignette('scoped-bot-setup', package = 'slackr')`
- Option 2 setup: `vignette('webhook-setup', package = 'slackr')`
- Usage: `vignette('using-slackr', package = 'slackr')`

**Important Note:** The setup process for `Option 2` and `Option 3` are
roughly the same, with only slightly differing scopes.

### Config File Setup

The `slackr_setup()` function will try to read setup values from a
`~/.slackr` (you can change the default filepath by recording in the
SLACKR_CONFIG_FILE_PATH environment variable or supplying as an argument
to the `config_file` parameter) configuration file, which may be easier
and more secure than passing them in manually (plus, will allow you to
have multiple `slackr` configurations for multiple Slack.com teams).

The file is in Debian Control File (DCF) format since it really doesn’t
need to be JSON and R has a handy `read.dcf()` function since that’s
what `DESCRIPTION` files are coded in.

Here’s the basic format for the configuration file:

    token: xox*-<your app's token>
    channel: #general
    username: slackr
    incoming_webhook_url: https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX
    icon_emoji: 'boom'

**As of `slackr 2.3.0`, you can create a config file with
`create_config_file()` instead of setting it up manually.** See the docs
for details.

You can also change the default emoji icon (from the one you setup at
integration creation time) with `icon_emoji`.

## Contributors

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

for their contributions to the package!

## Known Issues

- Depending on your scopes, `slackr` could quietly fail (i.e. not throw
  an error, but also not post anything to your channel). If this
  happens, try explicitly adding the app you’re trying to have `slackr`
  post as to the channel you want in your Slack workspace with
  `/invite @your_app_name` or make sure you have `chat:write.public`
  enabled.
