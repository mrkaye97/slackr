Tests and Coverage
================
07 February, 2019 21:54:34

-   [Coverage](#coverage)
-   [Unit Tests](#unit-tests)

This output is created by [covrpage](https://github.com/metrumresearchgroup/covrpage).

Coverage
--------

Coverage summary is created using the [covr](https://github.com/r-lib/covr) package.

| Object                                         | Coverage (%) |
|:-----------------------------------------------|:------------:|
| slackr                                         |     34.50    |
| [R/delete\_slackr.R](../R/delete_slackr.R)     |     0.00     |
| [R/dev\_slackr.R](../R/dev_slackr.R)           |     0.00     |
| [R/edit\_slackr.R](../R/edit_slackr.R)         |     0.00     |
| [R/gg\_slackr.R](../R/gg_slackr.R)             |     0.00     |
| [R/history\_slackr.R](../R/history_slackr.R)   |     0.00     |
| [R/register\_onexit.R](../R/register_onexit.R) |     0.00     |
| [R/save\_slackr.R](../R/save_slackr.R)         |     0.00     |
| [R/tex\_slackr.R](../R/tex_slackr.R)           |     0.00     |
| [R/slackr.R](../R/slackr.R)                    |     25.35    |
| [R/error\_checking.R](../R/error_checking.R)   |     28.57    |
| [R/slackr\_setup.r](../R/slackr_setup.r)       |     40.00    |
| [R/slackr\_upload.R](../R/slackr_upload.R)     |     50.00    |
| [R/slackr\_utils.R](../R/slackr_utils.R)       |     70.97    |
| [R/text\_slackr.r](../R/text_slackr.r)         |     77.27    |
| [R/slackr\_bot.r](../R/slackr_bot.r)           |     81.63    |

<br>

Unit Tests
----------

Unit Test summary is created using the [testthat](https://github.com/r-lib/testthat) package.

| file                                            |    n|    time|  error|  failed|  skipped|  warning| icon |
|:------------------------------------------------|----:|-------:|------:|-------:|--------:|--------:|:-----|
| [test-slackr.R](testthat/test-slackr.R)         |    6|  11.619|      0|       0|        0|        0|      |
| [test-textslackr.R](testthat/test-textslackr.R) |    1|   0.001|      0|       0|        1|        0| 🔶    |

<details open> <summary> Show Detailed Test Results </summary>

| file                                                  | context           | test                              | status  |    n|   time| icon |
|:------------------------------------------------------|:------------------|:----------------------------------|:--------|----:|------:|:-----|
| [test-slackr.R](testthat/test-slackr.R#L14)           | basic functioning | Webhook fails/works appropriately | PASS    |    2|  2.815|      |
| [test-slackr.R](testthat/test-slackr.R#L35_L37)       | basic functioning | Valid api tokens work             | PASS    |    4|  8.804|      |
| [test-textslackr.R](testthat/test-textslackr.R#L3_L8) | textslackr        | errors when given bad inputs      | SKIPPED |    1|  0.001| 🔶    |

| Failed | Warning | Skipped |
|:-------|:--------|:--------|
| 🛑      | ⚠️      | 🔶       |

</details>

<details> <summary> Session Info </summary>

| Field    | Value                               |
|:---------|:------------------------------------|
| Version  | R version 3.5.1 (2018-07-02)        |
| Platform | x86\_64-apple-darwin15.6.0 (64-bit) |
| Running  | macOS High Sierra 10.13.6           |
| Language | en\_US                              |
| Timezone | America/New\_York                   |

| Package  | Version |
|:---------|:--------|
| testthat | 2.0.1   |
| covr     | 3.2.1   |
| covrpage | 0.0.69  |

</details>

<!--- Final Status : skipped/warning --->
