packagedocs
-----------

Build an R package documentation website using [rmarkdown](http://rmarkdown.rstudio.com).  Example [here](http://hafen.github.io/rbokeh/).


## Installation

```s
devtools::install_github("hadley/staticdocs")
devtools::install_github("hafen/packagedocs")
```

## Usage

To initialize a packagedocs project, there is a simple intialization function to get things set up:

```s
packagedocs::packagedocs_init()
```

This will create a packagedocs project in a folder called "docs" in the current working directory.  See the help for this function for more customization.

## Notes

This was built primarily for my purposes where the goal is to have a main page for an R package with tutorial/vignette-like content paired with a web version of the .Rd documentation.  This package is similar to (and uses) [staticdocs](https://github.com/hadley/staticdocs) and supplants an earlier similar effort, [buildDocs](https://github.com/hafen/buildDocs).  That previous effort was quite hacky.  This current effort leverages rmarkdown to make it simpler and easier to embed htmlwidgets, etc.

Essentially this package provides a special template and format for rmarkdown with a few extra functions for building the web-based .Rd files.  If you like the template you can use it for non-package documentation purposes.

The template style is based on bootstrap with several customizations.  These are built using less and gulp with node.js.  These are not necessary for using the package, but for development, you can do `bower install` to get a dev environment going.
