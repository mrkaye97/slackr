
# 1.8.2
* Fixed various typos, added jpg for uploading, updated documentation, put webhook into travis and testing files 

# 1.8.1
* Updated tlmgr calls on travis. Attempting to fix travis build errors. 

# 1.6.0
* Adds caching of channels for improve performance. `slackr_setup()` includes `runcensus()` by default to reduce redundant requests. Improved error messages in `slackr_chtrans()`

# 1.5.2
* Fixes an issue with `slackr_ims()` where an inner join is performed which should be a left join.


# 1.5.1
* Resolves silent failure and error messages as requested in [#59](https://github.com/hrbrmstr/slackr/issues/59)

# 1.5.0

* TONS of improvements / additions
* Fixes CRAN issues

# 1.4.3

* Added `stop()` in `slackr_upload()` if file to upload was not found (via #46)

# 1.4.2

* Fixed bug introduced by new field names in Slack API
* Added a `NEWS.md` file to track changes to the package.

# 1.4.1

* There is a new `slackr_msg()` function which behaves slightly differently than `text_slackr()`
* Versions 1.4+ BREAK THINGS.
* Support has been removed for the "old style" incoming web hooks (see "Setup" in the README for the required incoming web hook URL format).
* the incoming webhook "token" is no longer required or used.
