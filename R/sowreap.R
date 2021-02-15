#' This is package `sowreap`
#'
#' Asynchroneous return with the Sow/Reap pattern
#'
#' @details
#' Complex workflows benefit from decoupling of generating results and returning them, i.e., values can returned anywhere without leaving a function.
#' This package allows you to use the Sow/Reap pattern for asynchroneous function returns. Use cases include larger software workflows, complicated, recursive algorithms, and reporting.
#' The basic idea is that an new function, `Sow`, can be called at any point to deposit a return value.
#' All sown values are later collected by the `Reap` function and return as a single list.
#' @seealso {Sow()} for basic examples

"_PACKAGE"
