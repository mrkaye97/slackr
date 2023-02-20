test_that("Connect + Auth", {
  skip_on_cran()
  set_up_test_env()

  expect_true(auth_test()$ok)
})
