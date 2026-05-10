# Check if most important input validation works.
test_that("passing two paths yields an error", {
  expect_error(c2dimport(path=c("path-1", "path-2")))
})

test_that("passing a non-existing path yields an error", {
  expect_error(c2dimport(path="this-file-should-not-exist"))
})

test_that("passing a file without .c2d (XML) content yields an error", {
  path <- withr::local_tempfile(
    pattern = "some-non-c2d-file",
    lines = c("some text content, but not XML", NULL)
  )
  expect_error(c2dimport(path=path))
})

# FIXME: Check read-in success with a REAL .c2d data file.
#        Also, use the same file in a vignette about example use,
#        so not sure if this should be a fixture or something else?
