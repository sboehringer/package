#
#	package.R
#Thu Feb 13 13:20:37 CET 2020
library('roxygen2');
library('package');

integrative_test = function() {
	tmp = tempdir();
	libPath = package:::Sprintf('%{tmp}s/lib');
	dir.create(libPath, recursive = TRUE, showWarnings = FALSE);
	capture.output(
		createPackage(system.file('Rscripts/pkg-minimal.R', package = 'package', noGit = T, lib = libPath))
	);
	roxygen2::load_installed(package:::Sprintf('%{tmp}s/pkg.minimal'));

	T1 = capture.output(myLittlePony());

	TestMe();
}
