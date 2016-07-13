



#' Deploy to Github Pages from Travis-CI
#'
#' @param email email for commit
#' @param name name for commit
#' @export
deploy_travis <- function(email = "travis@travis-ci.org", name = "Travis CI") {
  requireNamespace("devtools")

  # check if travis build number is available
  travis_build_number_char_len <- system("echo ${#TRAVIS_BUILD_NUMBER}", intern = TRUE) %>% as.numeric()
  if (travis_build_number_char_len == 0) {
    stop("'TRAVIS_BUILD_NUMBER' is not set")
  }

  # check if github token is available
  github_token_char_len <- system("echo ${#GITHUB_TOKEN}", intern = TRUE) %>% as.numeric()
  if (github_token == 0) {
    stop("'GITHUB_TOKEN' is not set")
  }

  user_repo <- gsub(
    ".*[:/]([^/]*/[^.]*)\\.git",
    "\\1",
    system("git config --get remote.origin.url")
  )


  # build the vigs
  devtools::build_vignettes()

  # move into the docs folder where the vigs are locally
  setwd(file.path("inst", "doc"))

  system(paste(
    "
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
    git push --force --quiet \"https://${GITHUB_TOKEN}@github.com/", user_repo, ".git\" master:gh-pages > /dev/null 2>&1
    "
    , sep = ""
  ))

}
