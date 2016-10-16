
#' Deploy to Github Pages from Travis-CI
#'
#' This function will generate both the CRAN vignettes and gh-pages vignettes. It will look for your personal github token (\code{GITHUB_TOKEN}) that the function may deploy to the gh-pages branch of the your package's github repo.
#'
#' The function is designed so that packagedocs will never ask for your token directly. It will only issue commands to the terminal which should evaluate with the necessary information.
#'
#' @param repo character string that has the form USER/REPO
#' @param valid_branches branch name(s) that are allowed to deploy
#' @param token_key key name that will be autofilled
#' @param email email for commit
#' @param name name for commit
#' @param push_branch branch the website should be pushed to. Defaults to 'gh-pages'
#' @param output_dir output directory to put the website in
#' @param build_fn function to build the documentation. This function must take \code{ouput_dir} and \code{...} for future expansion.  Defaults to \code{packagedocs::\link{build_vignettes}}
#' @export
deploy_travis <- function(
  # remove the href or git@github at the beginning and only keep USER/REPO
  repo = gsub(
    ".*://([^.]*)\\.github.io/([^/]*).*",
    "\\1/\\2",
    read_rmd_yaml(file.path("vignettes", "docs.Rmd"))$redirect
  ),
  valid_branches = "master",
  token_key = "GITHUB_PAT",
  email = "travis@travis-ci.org",
  name = "Travis CI",
  push_branch = "gh-pages",
  output_dir = "_gh-pages",
  build_fn = function(ouput_dir, ...) {
    build_vignettes(pkg = ".", output_dir = output_dir)
  }
) {

  repo <- force(repo)

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
    cat("Branch '", travis_branch, "' is not allowed to deploy. Valid branches: c('", paste(valid_branches, collapse = "', '"), "') Exiting", sep = "")
    return(invisible())
  }

  if (travis_pull_request != "false") {
    cat("Pull requests are not allowed to deploy. Recieved value: '", travis_pull_request, "'. Exiting", sep = "")
    return(invisible())
  }

  # build the vigs
  build_fn(output_dir = output_dir)

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
    git config --global user.email \"", email, "\"
    git config --global user.name \"", name, "\"

    # deploy
    git init      # resets the repo in the website folder
    git add .     # add all files
    git commit -m \"Travis build: $TRAVIS_BUILD_NUMBER\"
    # push the above commit and force it on the 'gh-pages' branch
    # since it's coming from a \"new\" repo, this is the master branch

    echo \"Attempting a silent push to '", repo, "@", push_branch, "'\"
    git push --force --quiet \"https://${", token_key, "}@github.com/", repo, ".git\" master:", push_branch, " > /dev/null 2>&1
    "
    , sep = ""
  ))
  # nolint end

}
