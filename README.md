# packagedocs

[![Build Status](https://travis-ci.org/hafen/packagedocs.svg?branch=master)](https://travis-ci.org/hafen/packagedocs)

packagedocs provides a mechanism for simple generation and automated deployment nice-looking online R package documentation that plugs into the traditional R package vignette system.  Example for this package [here](http://hafen.github.io/packagedocs).

## Features

- All documentation is generated from a single file, `"vignettes/docs.Rmd"`
- Documentation is nicely styled and responsive for mobile viewing with a collapsible auto-scrolling table of contents
- Simple Github / TravisCI hooks for automatically building and deploying documentation to your github pages branch after each commit
- Github pages branch is stomped on each commit to prevent repository bloat
- Once configured, any commits pushed to the master branch of repository https://github.com/username/reponame will have docs made automatically available at https://username.github.io/reponame
- Valid R vignettes are generated that point to the live version of the docs
- Support for [lazy rendering](https://github.com/hafen/lazyrmd) of htmlwidget outputs, useful when embedding several visualizations in a vignette
- Automatic generation of all R object and function documentation, called the "function reference"
- Examples in the function reference are evaluated and the output, including graphics is included inline with the documentation
- The function reference can be organized into groups with custom headings using a yaml configuration file
- A convenience function is provided for linking references to functions in your vignette directly to the associated function documentation on the generated function reference page
- Helper functions to initialize, run, and set up your docs for Github deployment

## Installation

```s
devtools::install_github("hafen/packagedocs")
```

## Usage

There are three main functions.

To initialize your packagedocs documentation:

```r
# in current package directory
packagedocs::init_vignettes()
```

This will create some files in your package's `"vignettes"` directory.  Edit `"vignettes/docs.Rmd`" and to generate your vignettes, run:

```r
packagedocs::build_vignettes()
```

To set up your repository to automatically build and deploy to your github pages branch on every commit:

```r
packagedocs::use_travis()
```

More detail about how to use these is found in the package's [documentation](http://hafen.github.io/packagedocs).

## Acknowledgements

This package has gone through several iterations, and was heavily influenced and borrows from Hadley Wickham's staticdocs (now [pkgdown](https://github.com/hadley/pkgdown)) package.
