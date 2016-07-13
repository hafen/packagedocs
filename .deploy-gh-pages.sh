#!/bin/bash

# Altered from: http://ricostacruz.com/cheatsheets/travis-gh-pages.html
# Original: https://medium.com/@nthgergo/publishing-gh-pages-with-travis-ci-53a8270e87db
set -o errexit

set -x

# if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "master" ]; then
#   exit 0;
# fi

# config
git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"

# build
Rscript -e 'devtools::build_vignettes()'

# deploy
cd inst/doc
git init      # resets the repo in the website folder
git add .     # add all files
git commit -m "Travis build: $TRAVIS_BUILD_NUMBER"
# push the above commit and force it on the gh-pages branch
# since it's coming from a "new" repo, this is the master branch
git push --force --quiet "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" master:gh-pages > /dev/null 2>&1


#
#
#
#
#
# # structure taken from: https://gist.github.com/willprice/e07efd73fb7f13f917ea
#
#
# setup_git() {
#   git config --global user.email "travis@travis-ci.org"
#   cit config --global user.name "Travis CI"
# }
#
# commit_website_files() {
#   git checkout -b gh-pages
#   git add . *.html
#   git commit --message "Travis build: $TRAVIS_BUILD_NUMBER"
# }
#
#
# push_gh_pages_folder() {
#   # http://www.damian.oquanta.info/posts/one-line-deployment-of-your-site-to-gh-pages.html
#   # Updated section
#
#   # Add repo to local git and don't report anything
#   git remote add origin-pages https://${GH_TOKEN}@github.com/schloerke/packagedocs.git > /dev/null 2>&1
#
#   # make a branch of this folder "gh-pages" and track it at "gh-pages"
#   git subtree split --prefix gh-pages -b origin-pages:gh-pages
#
#   # push the gh-pages branch out
#   git push -f origin-pages gh-pages:gh-pages
#
#   # delete the local branch
#   git branch -D gh-pages
#
#   # repeat
# }
#
# upload_files() {
#   git remote add origin-pages https://${GH_TOKEN}@github.com/MVSE-outreach/resources.git > /dev/null 2>&1
#   git push --quiet --set-upstream origin-pages gh-pages
# }
