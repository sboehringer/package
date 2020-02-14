#
#	package.R
#Thu Feb 13 13:20:37 CET 2020
library('roxygen2');

integrative_test = function() {
	tmp = tempdir();
	libPath = Sprintf('%{tmp}s/lib');
	dir.create(libPath, recursive = TRUE, showWarnings = FALSE);
	createPackage(system.file('Rscripts/pkg-minimal.R', package = 'package'), lib = libPath);
	roxygen2::load_installed(Sprintf('%{tmp}s/pkg.minimal'));

	T1 = capture.output(myLittlePony());

	TestMe();
}