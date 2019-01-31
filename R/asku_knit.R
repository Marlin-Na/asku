
# https://stackoverflow.com/questions/32944715/conditionally-display-block-of-markdown-text-using-knitr

#' Javascript and css dependency for asku
#'
#' @return A html dependency.
#' @export
asku_dependency <- function() {
    ans <- htmltools::htmlDependency(
        name = "asku_binding", version = "0.0.1",
        src = c(file = system.file("asku_binding", package = "asku", mustWork = TRUE)),
        script = "asku_binding.js", stylesheet = "asku_binding.css"
    )
    ans
}

#' asku knitr engine
#'
#' @param options Options given by knitr.
#' @export
asku_eng <- function(options) {
    #print(options)

    # Get Question
    asku.Q <- options$Q
    asku.A <- options$A
    if (is.null(asku.Q))
        asku.Q <- "What's the answer?"
    if (is.null(asku.A)) {
        # Should it have a default answer?
        warning("'A' option is not specified for asku engine. Use a random integer within 1-100.")
        asku.A <- as.character(sample(1:100, 1))
    }
    # Get the source
    src <- options$code
    if (is.null(src))
        src <- ""

    is.md <- options$is.md
    if (is.null(is.md))
        is.md <- TRUE

    out <- asku(content = src, Q = asku.Q, A = asku.A, is.md = is.md)

    # I have already attached the dependency, but it does not seem to work.
    # Thus I just add dependency to knit meta manually.
    knitr::knit_meta_add(list(asku_dependency()), options$label)

    # TODO:
    # options$size   --> ?? (default normalsize)
    # options$label   --> use it for div id??
    options$echo <- FALSE
    options$results <- "asis"
    #options$engine <- "r"

    knitr::engine_output(options, code = options$code, out = knitr::knit_print(out),
                         extra = NULL)
}

#' Hide your content in html
#'
#' @param content Character representing the content that will be hidden in
#' the generated html document.
#' @param Q Question promoted to the user.
#' @param A The correct answer expected.
#' @param is.md Is the content in markdown format or in raw html?
#'
#' @return A "shiny.tag" S3 object.
#' @export
#' @examples
#' frag <- asku(content = "## Header\n\n- list **item1**\n- list *item2*", A = "42")
#' frag
#' htmltools::browsable(frag)
asku <- function(content, Q = "What's the answer?", A, is.md = TRUE) {
    if (is.md)
        content <- markdown::markdownToHTML(text = content, fragment.only = TRUE)
    ## TODO: encrypt it. Currently I just convert it to base64
    #hidden.content <- base64enc::base64encode(charToRaw(content))
    hidden.content <- RCurl::base64Encode(content)
    #hidden.content <- safer::encrypt_string(content, key = A)

    out <- local({
        div    <- htmltools::div
        a      <- htmltools::a
        form   <- htmltools::tags$form
        input  <- htmltools::tags$input

        div(
            class = "asku_hidden_wrapper",
            hidden_data = hidden.content,
            hidden_ans = RCurl::base64Encode(A),
            # TODO: We should encrypt the content with the answer as key, then
            # store the hash of the original content.
            form(
                Q,
                input(type = "text", name = "askuA"),
                input(type = "submit", value = "Enter")
            )
        )
    })
    htmltools::attachDependencies(out, list(asku_dependency()))
}
