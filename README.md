slackr is a package to send webhook API messages to Slack.com channels/users

This package contains functions that make it possible to interact with slack messaging platform. When you need to share information/data from Rm rather than resort to copy/paste in e-mails or other services like Skype, you can use this package to send well-formatted output from multiple R objects and expressions to all teammates at the same time with little effort.

The following functions are implemented:

-   `slackrSetup` : initialize necessary environment variables
-   `slackr` : send stuff to slackr

### News

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

``` {.r}
library(testthat)

date()
```

    ## [1] "Thu Sep  4 12:00:00 2014"

``` {.r}
test_dir("tests/")
```

    ## basic functionality :
