test_that("package exposes wrapper-only API", {
  expect_true(exists("nwau_calculate"))
  expect_true(exists("nwau_acute"))
  expect_true(exists("nwau_ed"))
  expect_true(exists("nwau_non_admitted"))
  expect_true(exists("nwau_diagnose"))
})

test_that("diagnose reports CLI failures without formula fallback", {
  result <- nwau_diagnose(
    data.frame(DRG = "801A", LOS = 1),
    stream = "acute",
    python = "definitely-not-a-python-binary"
  )

  expect_false(result$ok)
  expect_true(result$status != 0L)
  expect_true(any(grepl("definitely-not-a-python-binary", result$command)))
})
