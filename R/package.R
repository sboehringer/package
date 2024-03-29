#' This is package `package`
#'
#' Create packages from R-code directly
#'
#' @details
#' This package simplifies package generation by automating the use of `devtools` and `roxygen`. It also makes the development workflow more efficient by allowing ad-hoc development of packages. Use `?"package-package"` for a tutorial or visit the project wiki (belonging to the source repository).
#' This package allows you to create a full-fledged R-package from a single R-file reducing the added work-load for maintaining a package to a minimum. Depending on the project, collections of files can be used and configuration can be seperated into a stand-alone configuration file, providing full flexibility. It can also handle git interaction. This package is created with itself and you can look at the single R-file `Rpackage.R` for a self-referring example.
#' The package contains a self-contained package example defined in the single R-file \code{pkg-minimal.R} which can be inspected and installed as in the example below.
#' @examples
#' \dontrun{
#'  file.show(system.file('Rscripts/pkg-minimal.R', package = 'package'))
#'  createPackage(system.file('Rscripts/pkg-minimal.R', package = 'package'))
#' }
#' @seealso {createPackage()} for starting the main workflow

"_PACKAGE"
