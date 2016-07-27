

is_self_contained_build_default <- function() {
  FALSE
}
is_self_contained_build <- (function() {
  is_contained <- is_self_contained_build_default()
  function(val) {
    if (missing(val)) {
      return(is_contained)
    }
    is_contained <<- as.logical(val)
    return(is_contained)
  }
})()

is_cran_build_default <- function() {
  TRUE
}
is_cran_build <- (function() {
  is_cran <- is_cran_build_default()
  function(val) {
    if (missing(val)) {
      return(is_cran)
    }
    is_cran <<- as.logical(val)
    return(is_cran)
  }
})()


#' Deploy to Github Pages from Travis-CI
#'
#' @param repo character string that has the form USER/REPO
#' @param valid_branches branch name(s) that are allowed to deploy
#' @param token_key key name that will be autofilled
#' @param email email for commit
#' @param name name for commit
#' @param output_dir output directory to put the website in
#' @export
deploy_travis <- function(
  # remove the href or git@github at the beginning and only keep USER/REPO
  repo = gsub(
    ".*[:/]([^/]*/[^.]*)\\.git",
    "\\1",
    system("git config --get remote.origin.url", intern = TRUE)
  ),
  valid_branches = "master",
  token_key = "GITHUB_TOKEN",
  email = "travis@travis-ci.org",
  name = "Travis CI",
  output_dir = "_gh-pages"
) {
  requireNamespace("devtools")

  # Altered from: http://ricostacruz.com/cheatsheets/travis-gh-pages.html
  # Original: https://medium.com/@nthgergo/publishing-gh-pages-with-travis-ci-53a8270e87db

  exists_or_stop <- function(key) {
    system(paste("echo ${#", key, "}", sep = ""), intern = TRUE) %>%
      as.numeric() ->
    char_len
    if (char_len == 0) {
      stop(paste("'", key, "' is not set", sep = ""))
    }
    invisible()
  }

  # check if travis build number is available
  exists_or_stop("TRAVIS_BUILD_NUMBER")
  # check if github token is available
  exists_or_stop(token_key)

  exists_or_stop("TRAVIS_PULL_REQUEST")
  exists_or_stop("TRAVIS_BRANCH")

  travis_pull_request <- Sys.getenv("TRAVIS_PULL_REQUEST")
  travis_branch <- Sys.getenv("TRAVIS_BRANCH")

  if (! (travis_branch %in% valid_branches)) {
    cat("Branch not allowed to deploy. Exiting")
    return()
  }

  if (travis_pull_request != "false") {
    cat("Pull requests are not allowed to deploy. Exiting")
    return()
  }

  # build the vigs
  build_vignettes(pkg = ".", output_dir = output_dir)

  # move into the docs folder where the vigs are locally
  wd <- getwd()
  on.exit({
    setwd(wd)
  })
  setwd(output_dir)

  # since travis is a clean pull each time, we can init in the inst/doc folder
  #   without worrying about already existing

  # nolint start
  system(paste(
    "set -e

    # config
    git config --global user.email \"travis@travis-ci.org\"
    git config --global user.name \"Travis CI\"

    # deploy
    git init      # resets the repo in the website folder
    git add .     # add all files
    git commit -m \"Travis build: $TRAVIS_BUILD_NUMBER\"
    # push the above commit and force it on the gh-pages branch
    # since it's coming from a \"new\" repo, this is the master branch

    echo \"Attempting a silent push to '", repo, "@gh-pages'\"
    git push --force --quiet \"https://${", token_key, "}@github.com/", repo, ".git\" master:gh-pages > /dev/null 2>&1
    "
    , sep = ""
  ))
  # nolint end

}
