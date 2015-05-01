packagedocs
-----------

Build an R package documentation website using [rmarkdown](http://rmarkdown.rstudio.com).  Example [here](http://hafen.github.io/rbokeh/).

## Notes

This was built primarily for my purposes where the goal is to have a main page for an R package with tutorial/vignette-like content paired with a web version of the .Rd documentation as well.  This package is similar to (and uses) [staticdocs](https://github.com/hadley/staticdocs) and supplants an earlier similar effort, [buildDocs](https://github.com/hafen/buildDocs).  That previous effort was quite hacky.  This current effort leverages rmarkdown to make it simpler and easier to embed htmlwidgets, etc.

Essentially this package provides a special template and format for rmarkdown with a few extra functions for building the web-based .Rd files.  If you like the template you can use it for non-package documentation purposes.

The template style is based on bootstrap with several customizations.  These are built using less and gulp with node.js.  These are not necessary for using the package, but for development, you can do `bower install` to get a dev environment going.

## Installation

```
devtools::install_github("hadley/staticdocs")
devtools::install_github("hafen/packagedocs")
```

## Usage

See `build.R` and `index.Rmd` and `rd_skeleton.Rmd` files [here](https://github.com/hafen/hafen.github.io/tree/master/rbokeh).

