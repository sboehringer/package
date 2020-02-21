#
#	package.R
#Thu Feb 13 13:20:37 CET 2020
library('roxygen2');
library('devtools');
library('package');

integrative_test = function() {
	tmp = tempdir();
	libPath = package:::Sprintf('%{tmp}s/package-tests-lib');
	dir.create(libPath, recursive = TRUE, showWarnings = FALSE);
	Sys.setenv(R_TESTS = '');
	capture.output(
		createPackage(
			system.file('Rscripts/pkg-minimal.R', package = 'package'),
			doInstall = TRUE, noGit = TRUE, doCheck = FALSE, lib = libPath
		)
	);
	pkgFolder = package:::Sprintf('%{libPath}s/pkg.minimal');
	roxygen2::load_installed(pkgFolder);

	T1 = capture.output(myLittlePony());
	T2 = file.exists(pkgFolder);

	TestMe();
}
