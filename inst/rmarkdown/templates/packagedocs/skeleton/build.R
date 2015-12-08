## install packagedocs if not installed:
# options(repos = c(tessera = "http://packages.tessera.io",
#   getOption("repos")))
# install.packages("packagedocs")

knitr::opts_knit$set(root.dir = normalizePath("{{{docs_path}}}"))

packagedocs::render_docs(
  code_path = "{{{code_path}}}",       # location of code directory
  docs_path = "{{{docs_path}}}",       # location of docs directory
  package_name = "{{{package_name}}}", # name of the package
  main_toc_collapse = TRUE,            # use collapsing toc on main page
  rd_toc_collapse = TRUE,              # use collapsing toc on rd page
  lib_dir = "assets",                  # put assets in "assets" directory
  render_main = TRUE,                  # render main page
  render_rd = TRUE,                    # render rd page
  view_output = TRUE,                  # look at the output after render
  rd_index = NULL                      # optional path to rd layout yaml
)
