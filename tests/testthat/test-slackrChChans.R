context("slackrChTrans")
slackrSetup(config_file='~/Dropbox/git/slackr/config.txt')

test_that("returned object looks as expected", {
	id <- slackrChTrans('#general')
	expect_is(id, 'character')
	expect_identical(length(id), 1L)
})

test_that("returns input if not found", {
	channel <- "aaa___zzz" # garbage name
	id <- slackrChTrans(channel)
	expect_identical(id,channel)
})

test_that("works with multiple channels", {
	ids <- slackrChTrans(c('#general','#random'))
	expect_identical(length(ids), 2L)
})