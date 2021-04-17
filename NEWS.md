# slackr 2.3.0

* Adds `slackr_csv()`, which simplifies the process of writing data frames to Slack as csv files
* Adds `slackr_teardown()`, which reverts the changes made by `slackr_setup()` by unsetting the environment variables
* Adds `create_config_file()` to simplify the process of setting up a config file
* `save_slackr()` is now deprecated in favor of `slackr_save()` and `tex_slackr()` has been deprecated in favor of `slackr_tex()`

# slackr 2.2.0

* Gets rid of the usage of `slackr_chtrans()` in the vast majority of functions, significantly speeding up `slackr_***()` by limiting API requests

# slackr 2.1.3

* Fixes a `memoise` bug that was causing `slackr_chtrans()` to fail with `memoise < 2.0.0`
* Fixes a bug in the implementation of `slackr_census()` that would cause `slackr_census()` to fail if the user was specifying a cache dir on the disk

# slackr 2.1.2

* Fixes the vignettes, so they knit again and are displayed on the `pkgdown` site

# slackr 2.1.1

* Changes a few badly-set function default channels to be `Sys.getenv('SLACK_CHANNEL')` instead of `''`
* Adds a more informative error message on `slackr_upload()` when the request returns `not authed` as per #137 
* Deprecates some arguments in `slackr_bot()` that no longer work (username, channel, icon emoji) that used to work with the old API structure

# slackr 2.1.0

* HTTP Caching speeds up requests and limits the number of requests we need to make
* `slackr_history()` and `slackr_delete()` are now implemented
* `username` and `icon_emoji` parameters to `slackr_***` functions now work again
* [https://mrkaye97.github.io/slackr/articles/webhook-setup.html](https://mrkaye97.github.io/slackr/articles/webhook-setup.html) have been added with setup instructions and usage
* Improved error messaging
* Updates to the README and the [pkgdown site](https://mrkaye97.github.io/slackr/)
* A number of significant back-end changes, thanks to [Andrie de Vries](https://github.com/andrie), including significant code cleanup, simplification of the API calls, pagination, and more!

# slackr 2.0.2

* A few more bug fixes and sets up CI with GH Actions

# slackr 2.0.1

* Documentation and suggested fixes to common bugs

# slackr 2.0.0

* Fixes to work with new Slack API

# slackr 1.5.0

* TONS of improvements / additions
* Fixes CRAN issues

# slackr 1.4.3

* Added `stop()` in `slackr_upload()` if file to upload was not found (via #46)

# slackr 1.4.2

* Fixed bug introduced by new field names in Slack API
* Added a `NEWS.md` file to track changes to the package.

# slackr 1.4.1

* There is a new `slackr_msg()` function which behaves slightly differently than `text_slackr()`
* Versions 1.4+ BREAK THINGS.
* Support has been removed for the "old style" incoming web hooks (see "Setup" in the README for the required incoming web hook URL format).
* the incoming webhook "token" is no longer required or used.

