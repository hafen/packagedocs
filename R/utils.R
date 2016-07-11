
# If a is null, then b
if_null <- function(a, b) {
  if (!is.null(a)) {
    a
  } else {
    b
  }
}
