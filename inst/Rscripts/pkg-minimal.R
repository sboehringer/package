#
#	pkg-minimal.R
# Fri Nov 22 17:22:55 CET 2019
#

packageDefinition = list(
	name = 'pkg.minimal',
	files = c(),
	instFiles = c(),
	description = list(
		title = 'Minimal R-package created with `package`',
		# version to be documented in news section
		#version = '0.1-0',
		author = 'Stefan Boehringer <r-packages@s-boehringer.org>',
		description = 'This appears in the package-documentaion, the markdown of the git-repository and in the package details. This package exports a single function, \\code{myLittlePony}, which prints a surprising message.',
		depends = c(),
		suggests = c(),
		license = 'LGPL',
		news = "0.1-0	Initial release"
	),
	git = list(
		readme = 'Toy package to demonstrate R-package `package`.',
		push = F,
		pushOnNewVersion = F
	)
);

#' Subject yourself to a message
#' 
#' This function will subject yourself to a message
#' 
#' @author Stefan Böhringer, \email{r-packages@@s-boehringer.org}
#' @examples
#' 
#' myLittlePony()
#'
#' @export myLittlePony
myLittlePony = function() {
	print('this is pateta');
}
