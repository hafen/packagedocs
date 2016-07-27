# packagedocs [![Build Status](https://travis-ci.org/schloerke/packagedocs.svg?branch=master)](https://travis-ci.org/schloerke/packagedocs)


Build an R package documentation website using [rmarkdown](http://rmarkdown.rstudio.com).  Example [here](http://hafen.github.io/rbokeh/) or ([here](http://tessera.io/docs-datadr/)).

## Installation

<!-- Simple installation:

```s
options(repos = c(tessera = "http://packages.tessera.io",
  getOption("repos")))
install.packages("packagedocs")
``` -->

From github with devtools:

```s
devtools::install_github("schloerke/packagedocs")
```

## Vignettes

To initialize vignettes for both the function reference and home page, run:

```{r}
# in current package directory
packagedocs::init_vignettes()
```

To generate your vignettes, run:

```{r}
packagedocs::build_vignettes()
```

For more information, please visit the [`packagedocs` documentation](https://schloerke.github.io/packagedocs)
