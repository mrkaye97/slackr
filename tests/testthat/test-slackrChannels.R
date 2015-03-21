context("slackrChannels")
slackrSetup(config_file='~/Dropbox/git/slackr/config.txt')

test_that("returned object looks as expected", {
	channels <- slackrChannels()
	expect_is(channels, 'data.table')
	expect_less_than(0, nrow(channels))
	expect_identical(names(channels),c('id','name','is_member'))
})