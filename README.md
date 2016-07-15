# packagedocs [![Build Status](https://travis-ci.org/schloerke/packagedocs.svg?branch=master)](https://travis-ci.org/schloerke/packagedocs)


Build an R package documentation website using [rmarkdown](http://rmarkdown.rstudio.com).  Example [here](http://hafen.github.io/rbokeh/) or ([here](http://tessera.io/docs-datadr/)).

## Installation

Simple installation:

```s
options(repos = c(tessera = "http://packages.tessera.io",
  getOption("repos")))
install.packages("packagedocs")
```

From github with devtools:

```s
devtools::install_github("hafen/packagedocs")
```

<!-- ## Usage

To initialize a packagedocs project, there is a simple initialization function to get things set up:

```s
packagedocs::packagedocs_init()
```

This will create a packagedocs project in a folder called "docs" in the current working directory.  See the help for this function for more customization.
 -->

## Vignettes

To initialize vignettes for both the function reference and home page, run:

```{r}
# in current package directory
packagedocs::init_vignettes()
```

This will create two packagedocs vignette `.Rmd` files in the `vignettes` folder. This function will read the local `DESCRIPTION` file for any necessary information.  I recommend initializing your vignettes once your package is no longer rapidly changing.

### Generated Files

Three files will be created in the `vignettes` folder: `index.Rmd`, `rd_index.yaml`, and `rd.Rmd`.  

#### `index.Rmd`

The `index.Rmd` file is the home webpage for your package's documentation. The main content has very little structure, allowing you to insert any `rmarkdown` formatted document.  The `index.Rmd` file is a great place to show off long examples that regular function documentation can not do justice.  The classic RStudio rmarkdown example has been inserted by default.

#### `rd_index.yaml`

The `rd_index.yaml` is a yaml file that contains the layout for the `rd.Rmd` file.  It contains a list of `section` and `topics` pairs.  Each `topic` can either be a single character string containing the name of the function alias (typically the function name) or an object containing the keys `file` and `title`.  `file` should provide the function alias name (ending in `.Rd`), and `title` will be displayed as the title for the help topic.

The sections in the `rd_index.yaml` file are auto-generated according to the keywords used in the package documentation.  All functions that do not have a keyword will be placed in the last section.  `internal` keyword functions will not be added automatically.

It is okay to rename, remove, or rearrange the sections and topics!

#### `rd.Rmd`

This file is a shell file that will be filled with compiled `rd_index.yaml` information.  The compiled `rd_index.yaml` information will be appended to the `rmarkdown` document.  Feel free to add any information about the functions that you'd like users to see first!

### Compilation

Compiling the vignettes works like other vignettes:

```{r}
devtools::build_vignettes()
```

The resulting standalone html output will be stored in `inst/doc`.

## Vignette Engines

There is two `index.Rmd` vignette engines:

* `%\VignetteEngine{packagedocs::index}`.
  * This will collapse the left side table of contents. This is the default auto-generated engine.
* `%\VignetteEngine{packagedocs::index_no_collapse}`
  * This will **NOT** collapse the left side table of contents.

There are four `rd.Rmd` vignette engines:

* `%\VignetteEngine{packagedocs::rd_run_examples}`
  * This will run all examples in each topic and collapse the left side table of contents.  This is the default auto-generated engine.
* `%\VignetteEngine{packagedocs::rd_no_run_examples}`
  * This will **NOT** run any examples in the topics but will still collapse the left side table of contents.
* `%\VignetteEngine{packagedocs::rd_run_examples_no_collapse}`
  * This will run all examples in each topic, but will **NOT** collapse the left side table of contents.
* `%\VignetteEngine{packagedocs::rd_no_run_examples_no_collapse}`
  * This will **NOT** run any examples in the topics and will **NOT** collapse the left side table of contents.


## Notes

This was built primarily for my purposes where the goal is to have a main page for an R package with tutorial/vignette-like content paired with a web version of the .Rd documentation.  This package is similar to (and uses) [staticdocs](https://github.com/hadley/staticdocs) and supplants an earlier similar effort, [buildDocs](https://github.com/hafen/buildDocs).  That previous effort was quite hacky.  This current effort leverages rmarkdown to make it simpler and easier to embed htmlwidgets, etc.

Essentially this package provides a special template and format for rmarkdown with a few extra functions for building the web-based .Rd files.  If you like the template you can use it for non-package documentation purposes.

The template style is based on bootstrap with several customizations.  These are built using less and gulp with node.js.  These are not necessary for using the package, but for development, you can do `bower install` to get a dev environment going.

Tip: Usually I put my package docs inside a "docs" directory inside my package root directory.  However, I really dislike checking this directory in with the package repository on github, or even in the same repository's `gh-pages` branch.  The reason for this is that package documentation can carry a lot of baggage (raster images, large js, css, html files, etc.) that can be github-unfriendly or have nothing to do with the R package and quickly contaminate and bloat the source code repository.  Instead I usually create a separate github repo called "docs-*packagename*" and track the docs in the `gh-pages` directory of this repo.
