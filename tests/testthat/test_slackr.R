context('slackr')

test_that("non-syntactic grouping variable is preserved (#1138)", {
  testresult <- try(slackr("testing"), silent = T)

  expect_equal(testresult, NULL)
})
