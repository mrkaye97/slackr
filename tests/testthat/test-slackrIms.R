context("slackrIms")
slackrSetup(config_file='~/Dropbox/git/slackr/config.txt')

test_that("returned object looks as expected", {
	ims <- slackrIms()
	expect_is(ims, 'data.table')
	expect_less_than(0, nrow(ims))
	expect_identical(names(ims),c('id','name','user','real_name'))
})