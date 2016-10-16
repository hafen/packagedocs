
# If a is null, then b
if_null <- function(a, b) {
  if (!is.null(a)) {
    a
  } else {
    b
  }
}

str_replace <- function(x, pattern, replacement) {
  gsub(pattern, replacement, x)
}
