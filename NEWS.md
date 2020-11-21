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
