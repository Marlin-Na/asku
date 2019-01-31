#!/usr/bin/env Rscript

library(rmarkdown)
library(here)

dir.create("vignettes", showWarnings = FALSE)
file.create(here("vignettes/asku.Rmd"), showWarnings = FALSE)

# Pick up the file
system2("git", "show master:vignettes/asku.Rmd", stdout = "vignettes/asku.Rmd")

render(
    "vignettes/asku.Rmd",
    output_file = "index.html",
    output_format = rmarkdown::html_document(
        self_contained = FALSE
    ),
    output_dir = here::here()
)

