test_that("Connect + Auth", {
  set_up_test_env()

  expect_true(auth_test()$ok)
})
