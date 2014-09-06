slackr is a package to send webhook API messages to Slack.com channels/users

This package contains functions that make it possible to interact with slack messaging platform. When you need to share information/data from R, rather than resort to copy/paste in e-mails or other services like Skype, you can use this package to send well-formatted output from multiple R objects and expressions to all teammates at the same time with little effort. You can also send images from the current graphics device. , R objects (as RData), and upload files.

The following functions are implemented:

-   `slackrSetup` : initialize necessary environment variables
-   `slackr` : send stuff to slackr
-   `dev.slackr` : send the graphics contents of the current device to a to slack.com channel (full API token - i.e. not wehbook - required)
-   `save.slackr` : save R objects to an RData file on `slack.com`
-   `slackrUpload` : upload any file to `slack.com`
-   `slackrUsers` : get a data frame of slack.com users (full API token - i.e. not wehbook - required)
-   `slackrChannels` : get a data frame of slack.com channels (full API token - i.e. not wehbook - required)

The `slackrSetup()` function will try to read setup values from a `~/.slackr` (you can change the default) configuration file, which may be easier and more secure than passing them in manually (plus, will allow you to have multiple slackr configs for multiple Slack.com teams). The file is in Debian Control File (DCF) format since it really doesn't need to be JSON and R has a handy `read.dcf()` function since that's what `DESCRIPTION` files are coded in. Here's the basic format for the configuration file:

    token: YOUR_INCOMING_WEBHOOK_TOKEN
    channel: #general
    username: slackr
    incoming_webhook_url: https://YOUR_TEAM.slack.com/services/hooks/incoming-webhook?
    api_token: YOUR_FULL_API_TOKEN

You can also change the default emoji icon (from the one you setup at integration creation time) with `icon_emoji`.

### News

-   Version `1.1` released (added graphics & files capability)
-   Version `1.0` released

### Installation

``` {.r}
devtools::install_github("hrbrmstr/slackr")
```

### Usage

``` {.r}
library(slackr)

# current verison
packageVersion("slackr")


slackrSetup(channel="#code", 
            url_prefix="http://myslack.slack.com/services/hooks/incoming-webhook?")

slackr(str(iris))

# send images
library(ggplot2)
qplot(mpg, wt, data=mtcars)
dev.slackr("#results")

barplot(VADeaths)
dev.slackr("@jayjacobs")
```

### Test Results

``` {.r}
library(slackr)
```

    ## Loading required package: httr
    ## Loading required package: jsonlite
    ## 
    ## Attaching package: 'jsonlite'
    ## 
    ## The following object is masked from 'package:utils':
    ## 
    ##     View
    ## 
    ## Loading required package: data.table

``` {.r}
library(testthat)

date()
```

    ## [1] "Sat Sep  6 08:11:43 2014"

``` {.r}
test_dir("tests/")
```

    ## basic functionality :
