#
#	pkg-minimal.R
# Fri Nov 22 17:22:55 CET 2019
#

packageDefinition = list(
	name = 'pkg-minimal',
	files = c(),
	instFiles = list(),
	description = list(
		title = 'Minimal R-package created with `package`',
		# version to be documented in news section
		#version = '0.1-0',
		author = 'Stefan Böhringer <r-packages@s-boehringer.org>',
		description = 'This appears in the package-documentaion, the markdown of the git-repository and in th e package details. This package exports a single function, \\code{myLittlePony}, which prints a surprising message.',
		depends = c(),
		suggests = c(),
		license = 'LGPL',
		news = "0.1-0	Initial release"
	),
	git = list(
		readme = '## Installation\n```{r}\nlibrary(devtools);\ninstall_github("user/pkg-minimal")\n```\n',
		push = F,
		pushOnNewVersion = F
	)
);

#' Subject yourself to a message
#' 
#' This function will subject yourself to a message [no escape]
#' 
#' @aliases myLittlePony
#' @section Important details: \itemize{
#' \item Be prepared, as in: \code{f0 =
#' f1 = function(){42}; parallelize(f0); parallelize(f1);}
#' \item Be extra prepared
#' }
#' @author Stefan Böhringer, \email{r-packages@@s-boehringer.org}
#' @seealso %% ~~objects to See Also as \code{\link{help}}, ~~~
#' @keywords ~kwd1 ~kwd2
#' @examples
#' 
#' myLittlePony()
#'
#' @export myLittlePony
myLittlePony = function() {
	print('this is pateta');
}
