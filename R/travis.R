



#' Deploy to Github Pages from Travis-CI
#'
#' @param branch branch name(s) that are allowed to deploy
#' @param token_key key name that will be autofilled
#' @param email email for commit
#' @param name name for commit
#' @param allow_pulls allow pull requests to process. (defaults to FALSE)
#' @export
deploy_travis <- function(
  branch = "master",
  token_key = "GITHUB_TOKEN",
  email = "travis@travis-ci.org",
  name = "Travis CI",
  allow_pulls = FALSE
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

  if (! (travis_branch %in% branch)) {
    cat("Branch not allowed to deploy. Exiting")
    return()
  }

  if (travis_pull_request != "false" && allow_pulls) {
    cat("Pull requests are not allowed to deploy. Exiting")
    return()
  }

  # remove the href or git@github at the beginning and only keep USER/REPO
  user_repo <- gsub(
    ".*[:/]([^/]*/[^.]*)\\.git",
    "\\1",
    system("git config --get remote.origin.url", intern = TRUE)
  )

  # build the vigs
  devtools::build_vignettes()

  # move into the docs folder where the vigs are locally
  wd <- getwd()
  setwd(file.path("inst", "doc"))
  on.exit({
    setwd(wd)
  })

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

    echo \"Attempting a silent push to $GITHUB_REPO\"
    git push --force --quiet \"https://${", token_key, "}@github.com/", user_repo, ".git\" master:gh-pages > /dev/null 2>&1
    "
    , sep = ""
  ))
  # nolint end

}