# nolint start

# This file is taken directly from https://github.com/hadley/staticdocs/blob/master/R/util.r
# All @export tags were removed as it is only for internal use
#



# Return the staticdocs path for a package
# Could be in pkgdir/inst/staticdocs/ (for non-installed source packages)
# or in pkgdir/staticdocs/ (for installed packages)
pkg_sd_path <- function(package, site_path) {

  if(!is.null(package$sd_path)) return(package$sd_path)

  if(!missing(site_path) && !is.null(site_path)) {
    if(dir.exists(site_path))
      return(site_path)
    else
      stop("Folder site_path doesn't exist. Specify site_path or create a package folder inst/staticdocs.")
  }

  pathsrc <- file.path(package$path, "inst", "staticdocs")
  pathinst <- file.path(package$path, "staticdocs")

  if (dir.exists(pathsrc))
    pathsrc
  else if (dir.exists(pathinst))
    pathinst
  else
    stop("Folder inst/staticdocs doesn't exist. Specify site_path or create a package folder inst/staticdocs.")


}




"%||%" <- function(a, b) {
  if (!is.null(a)) a else b
}


# nolint end
