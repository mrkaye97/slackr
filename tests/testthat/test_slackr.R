context('slackr')

test_that("non-syntactic grouping variable is preserved (#1138)", {
  slackr::slackr_setup()
  testresult <- try(slackr::slackr("testing"), silent = T)

  expect_equal(testresult, NULL)
})
