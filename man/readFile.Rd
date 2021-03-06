% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Rsystem.R
\name{readFile}
\alias{readFile}
\title{Read content of file and return as character object.}
\usage{
readFile(path, prefixes = NULL, normalize = T, ssh = F)
}
\arguments{
\item{path}{Path to the file to be read.}

\item{prefixes}{Search for file by prepending character strings from
prefixes.}

\item{normalize}{Standardize pathes.}

\item{ssh}{Allow pathes to remote files in \code{scp} notation.}
}
\description{
Read content of file and return as character object.
}
\examples{
\dontrun{
  parallel8 = function(e) log(1:e) \%*\% log(1:e);
  cat(readFile(tempcodefile(parallel8)));
}
}
\author{
Stefan Böhringer <r-packages@s-boehringer.org>
}
\keyword{~kwd1}
\keyword{~kwd2}
