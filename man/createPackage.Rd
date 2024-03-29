% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Rpackage.R
\name{createPackage}
\alias{createPackage}
\title{Create package from vector of source files and single configuration}
\usage{
createPackage(
  packageDesc,
  packagesDir = "~/src/Rpackages",
  dir = NULL,
  doInstall = FALSE,
  doCheck = T,
  gitOptions = list(),
  noGit = F,
  lib = NULL,
  asCran = FALSE
)
}
\arguments{
\item{packageDesc}{path to the configuration file (R, extended plist format, json, yaml).
If an R-file is provided, it is sourced in a seperate environment and needs to define the variable
`packageDefinition`. This variable has to be a list which is further specified in the details below.
If a propertyList/JSON/YAML-file is provided, they have to parse into a list corresponding to
`packageDefinition`. Functions \code{propertyFromStringExt}, \code{read_json}, and \code{read_yaml} are
used for parsing, coming from packages \code{package}, \code{jsonlite}, and \code{yaml}.}

\item{packagesDir}{folder in which the folder structure of the package is written}

\item{dir}{directory to search for package definition}

\item{doInstall}{flag to indicate whether the package should also be installed}

\item{doCheck}{whether to run R CMD check --as-cran on the package}

\item{gitOptions}{list with options for git interaction}

\item{noGit}{boolean to suppress git calls, overwrites other options}

\item{lib}{Path to package library as forwarded to \code{install.packages}}

\item{asCran}{boolean to indicate whether check should be including --as-cran}
}
\description{
This function creates a package dir, runs documentation generation using roxygen and optionally installs the package. It can also update via git and manage version numbers. In a minimal configuration, a single file is sufficient to create a fully documented R package.
}
\details{
This function creates a valid R package folder with DESCRIPTION, LICENSE and NEWS files.
All R-files listed are copied to this directory and documentation is created by  
running the \code{devtools::document} function on this folder.
The package is specified through a list coming from an R script or configuration file.
The following elements control package generation. In this list \code{key1-key2} indicates a
sublist-element, i.e. it stand for \code{packageDefinition[[key1]][[key2]]}.

\itemize{
	\item{name: }{The name of the pacakge}
	\item{files: }{R-files to be put into the package. If an R-file is used for the configuration,
		it will automatically be include. This allows package definition through a single R-file.}
	\item{instFiles: }{Other files to be installed. This is a list, the names of which specify
		sub-folders in the \code{inst} sub-directory of the package. Values are character vectors
		specifying files to be put there.}
	\item{description: }{A sub-list with elements specifying the \code{DESCRIPTION} file of the package.}
	\item{description-title: }{The title of the help page 'package-myPackage' (myPackage is the name
		of the package) and the title fiedl in DESCRIPTION.}
	\item{description-author: }{The \code{Author} field in DESCRIPTION.
	\item{description-description: } The \code{Description} field in DESCRIPTION. The text is re-used
		for the package documentation as displayed by ?'package-myPackage' and is prepended to the 
		seperate package documentation. It is also inserted as a Description section of a Markdown file
		if git is used. This string should therefore not make use of roxygen/markdown markup.}
	\item{description-depends: }{A character vector with package dependencies.}
	\item{description-suggests: }{A character vector with package suggestions.}
	\item{description-news: }{A character vector with a single element containing the \code{NEWS}
		file of the package. It is assumed that a line starting with a non white space character
		indicates a new version. The version identifier is taken to be all characters until the
		first white space. Once a new version is detected, git actions might be triggered (see below).}
	\item{git: }{A sub-list specifying git behavior. If you do not
		want to use git, omit this entry from \code{packageDefinition}. If present, a git repository
		is created and maintained in the target folder. Default \code{git} settings for the package can be 
		overwritten using the  \code{gitOptions} argument.}
	\item{git-push: }{Logical, whether to push each commit, defaults to \code{FALSE}.}
	\item{git-pushOnNewVersion: }{Logical, whether to push each when a new release is created
		(see item \code{description-news}. Defaults to \code{TRUE}.
		A push is automatically performed, once a new release is created, irrespective of this setting.
		To suppress a push in these cases, push has to set to \code{FALSE} in the. }
	\item{git-readme: }{Character vector with single entry with the content of a readme file that is put
		as \code{README.md} into the package main folder. The description given under
		\code{description-description} is appended to this text.}
}
}
\examples{

packageDefinition = list(
	name = 'pkg-minimal',
	files = c(),
instFiles = list(),
	description = list(
		title = 'Minimal R-package created with `package`',
		# version to be documented in news section
		#version = '0.1-0',
		author = 'Stefan Böhringer <r-packages@s-boehringer.org>',
		description = 'This appears in the package-documentaion, the markdown of the git-repository and in the package details.',
		depends = c(),
		suggests = c(),
		license = 'LGPL',
		news = "0.1-0	Initial release"
	),
	git = list(
		readme = '## Installation\n```{r}\nlibrary(devtools);\ninstall_github("user/pkg-minimal")\n```\n',
		push = FALSE,
		pushOnNewVersion = FALSE
	)
);


}
\seealso{
package-package
}
\author{
Stefan Böhringer, \email{r-packages@s-boehringer.org}
}
\keyword{create}
\keyword{createPackage}
\keyword{package}
