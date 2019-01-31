
.onLoad <- function(libname, pkgname) {
    knitr::knit_engines$set(asku = asku_eng)
    invisible()
}
