# This file is taken directly from https://github.com/hadley/staticdocs/blob/master/R/build-index.r
# All @export tags were removed as it is only for internal use


compact <- function (x) Filter(function(x) !is.null(x) & length(x), x)
