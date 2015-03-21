context("slackrGroups")
slackrSetup(config_file='~/Dropbox/git/slackr/config.txt')

test_that("returned object looks as expected", {
	groups <- slackrGroups()
	expect_is(groups, 'data.table')
	expect_less_than(0, nrow(groups))
	expect_identical(names(groups),c('id','name','is_archived'))
})