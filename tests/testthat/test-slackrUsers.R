context("slackrUsers")
slackrSetup(config_file='~/Dropbox/git/slackr/config.txt')

test_that("returned object looks as expected", {
	users <- slackrUsers()
	expect_is(users, 'data.table')
	expect_less_than(0, nrow(users))
	expect_identical(names(users),c('id','name','real_name'))
})