

group_fn_by_keyword <- function(rd_info, default_value = NULL) {

  rd_list <- rd_info$rd
  rd_index <- rd_info$rd_index

  if (nrow(rd_index) == 0) {
    warning("no documentation found for package")
    return(
      list(
        section_name = "no topics found",
        topics = list(
          title = "function_name",
          is_unique = TRUE
        )
      )
    )
  }

  paste_com <- function(...) {
    paste(..., collapse = ", ")
  }
  rd_index$alias %>%
    lapply(paste_com) %>%
    unlist() ->
  rd_index$alias_functions

  rd_index$keyword <- lapply(
    rd_list[rd_index$file_in],
    get_keyword,
    default_value
  ) %>% unlist()
  unique_keywords <- unique(rd_index$keyword)

  if (!is.null(default_value)) {
    is_default <- unique_keywords == default_value

    unique_keywords <- c(unique_keywords[! is_default], unique_keywords[is_default])
  }

  unique_keywords <- unique_keywords[
    unique_keywords != keyword_info_map[["internal"]][2]
  ]

  rd_index$title <- ""
  rd_index$is_unique <- TRUE
  for (i in seq_len(nrow(rd_index))) {
    if (length(rd_index$alias[[i]]) == 1) {
      rd_index$title[i] <- gsub("\\.Rd", "", rd_index$file_in[[i]])
    } else {
      rd_index$is_unique[[i]] <- FALSE
      rd_index$title[i] <- paste(
          gsub("\\.Rd", "", rd_index$file_in[[i]]),
          ": ",
          rd_index$alias_functions[[i]],
          sep = ""
        )
    }
  }

  unique_keywords %>%
    lapply(function(unique_keyword) {
      sub_index <- rd_index[rd_index$keyword == unique_keyword, ]
      topics <- list()
      for (i in seq_len(nrow(sub_index))) {
        topics[[i]] <- list(
          file = sub_index$file_in[[i]],
          title = sub_index$title[[i]],
          is_unique = sub_index$is_unique[[i]]
        )
      }

      list(
        section_name = unique_keyword,
        topics = topics
      )
    })
}

#' @importFrom magrittr extract2
get_keyword <- function(rd_obj, default_value = NULL) {
  if (! inherits(rd_obj, "Rd_content")) {
    stop("rd_obj is not a Rd_content object")
  }

  rd_obj %>%
    lapply(class) %>%
    lapply(`%in%`, "keyword") %>%
    lapply(any) %>%
    unlist() %>%
    which() ->
  keyword_pos

  if (length(keyword_pos) == 0) {
    return(default_value)
  }

  rd_obj %>%
    extract2(keyword_pos) %>%
    extract2(1) %>%
    as.character() ->
  keyword_name

  keyword_info_map %>%
    extract2(keyword_name) %>%
    extract2(2) %>%
    if_null(default_value)
}

keyword_info_map <- list(
  aplot = c("Graphics", "Add to Existing Plot / internal plot"),
  dplot = c("Graphics", "Computations Related to Plotting"),
  hplot = c("Graphics", "High-Level Plots"),
  iplot = c("Graphics", "Interacting with Plots"),
  color = c("Graphics", "Color, Palettes etc"),
  dynamic = c("Graphics", "Dynamic Graphics"),
  device = c("Graphics", "Graphical Devices"),

  sysdata = c("Basics", "Basic System Variables"),
  datasets = c("Basics", "Datasets available by data()"),
  data = c("Basics", "Environments, Scoping, Packages"),
  manip = c("Basics", "Data Manipulation"),
  attribute = c("Basics", "Data Attributes"),
  classes = c("Basics", "Data Types (not OO)"),
  character = c("Basics", "Character Data (\"String\") Operations"),
  complex = c("Basics", "Complex Numbers"),
  category = c("Basics", "Categorical Data"),
  "NA" = c("Basics", "Missing Values"),
  list = c("Basics", "Lists"),
  chron = c("Basics", "Dates and Times"),
  package = c("Basics", "Package Summaries"),

  array = c("Mathematics", "Matrices and Arrays"),
  algebra = c("Mathematics", "Linear Algebra"),
  arith = c("Mathematics", "Basic Arithmetic and Sorting"),
  math = c("Mathematics", "Mathematical Calculus etc."),
  logic = c("Mathematics", "Logical Operators"),
  optimize = c("Mathematics", "Optimization"),
  symbolmath = c("Mathematics", "\"Symbolic Math\", as polynomials, fractions"),
  graphs = c("Mathematics", "Graphs, (not graphics), e.g. dendrograms"),

  programming = c("Programming, Input/Ouput, and Miscellaneous", "Programming"),
  interface = c("Programming, Input/Ouput, and Miscellaneous", "Interfaces to Other Languages"),
  IO = c("Programming, Input/Ouput, and Miscellaneous", "Input/output"),
  file = c("Programming, Input/Ouput, and Miscellaneous", "Files"),
  connection = c("Programming, Input/Ouput, and Miscellaneous", "Connections"),
  database = c("Programming, Input/Ouput, and Miscellaneous", "Interfaces to databases"),
  iteration = c("Programming, Input/Ouput, and Miscellaneous", "Looping and Iteration"),
  methods = c("Programming, Input/Ouput, and Miscellaneous", "Methods and Generic Functions"),
  print = c("Programming, Input/Ouput, and Miscellaneous", "Printing"),
  error = c("Programming, Input/Ouput, and Miscellaneous", "Error Handling"),
  environment = c("Programming, Input/Ouput, and Miscellaneous", "Session Environment"),
  internal = c("Programming, Input/Ouput, and Miscellaneous", "Internal Objects (not part of API)"),
  utilities = c("Programming, Input/Ouput, and Miscellaneous", "Utilities"),
  misc = c("Programming, Input/Ouput, and Miscellaneous", "Miscellaneous"),
  documentation = c("Programming, Input/Ouput, and Miscellaneous", "Documentation"),
  debugging = c("Programming, Input/Ouput, and Miscellaneous", "Debugging Tools"),

  datagen = c("Statistics", "Functions for generating data sets"),
  distribution = c("Statistics", "Probability Distributions and Random Numbers"),
  univar = c("Statistics", "simple univariate statistics"),
  htest = c("Statistics", "Statistical Inference"),
  models = c("Statistics", "Statistical Models"),
  regression = c("Statistics", "Regression"),
  nonlinear = c("Statistics", "Non-linear Regression"),
  robust = c("Statistics", "Robust/Resistant Techniques"),
  design = c("Statistics", "Designed Experiments"),
  multivariate = c("Statistics", "Multivariate Techniques"),
  ts = c("Statistics", "Time Series"),
  survival = c("Statistics", "Survival Analysis"),
  nonparametric = c("Statistics", "Nonparametric Statistics"),
  smooth = c("Statistics", "Curve (and Surface) Smoothing"),
  loess = c("Statistics", "Loess Objects"),
  cluster = c("Statistics", "Clustering"),
  tree = c("Statistics", "Regression and Classification Trees"),
  survey = c("Statistics", "Complex survey samples"),

  # MASS (2, 1997)
  # --------------
  # add the following keywords :
  classif = c("MASS", "Classification "), # ['class' package]
  spatial = c("MASS", "Spatial Statistics"), # ['spatial' package]
  neural = c("MASS", "Neural Networks") # ['nnet'  package]
)
