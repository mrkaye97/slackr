slackr is a package to send webhook API messages to Slack.com channels/users

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

    ## [1] "Thu Sep  4 09:18:20 2014"

``` {.r}
test_dir("tests/")
```

    ## basic functionality :
