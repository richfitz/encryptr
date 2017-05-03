context("ssh_keygen")

test_that("keygen", {
  path <- tempfile()
  res <- ssh_keygen(path, "secret")
  expect_equal(res, path)
  expect_true(is_directory(path))
  expect_true(file.exists(file.path(path, "id_rsa")))
  expect_true(file.exists(file.path(path, "id_rsa.pub")))
})

test_that("existing, but not directory", {
  path <- tempfile()
  writeLines("", path)
  on.exit(file.remove(path))
  expect_error(ssh_keygen(path), "path exists but is not a directory")
})

test_that("existing, but not directory", {
  path <- tempfile()
  dir.create(path)
  writeLines("", file.path(path, "id_rsa.pub"))
  expect_error(ssh_keygen(path), "public.*exists already -- not overwriting")
  writeLines("", file.path(path, "id_rsa"))
  expect_error(ssh_keygen(path), "private.*exists already -- not overwriting")
})

test_that("no password", {
  path <- tempfile()
  res <- ssh_keygen(path, FALSE)
  expect_is(openssl_load_key(path, ""), "key")
})

test_that("invalid password", {
  expect_error(ssh_keygen(tempfile(), 124), "Invalid input for password")
})

test_that("get password", {
  path <- tempfile()
  testthat::with_mock(
    `cyphr::get_password_str` = function(...) "secret",
    ssh_keygen(path, TRUE))
  expect_error(openssl_load_key(path, "wrong password"), "bad decrypt")
  expect_is(openssl_load_key(path, "secret"), "key")
})