#
#	Rpackage.R
#Thu Oct 17 16:52:03 CEST 2019

packageDefinition = list(
	name = 'package',
	files = c('Rmeta.R', 'Rdata.R', 'Rsystem.R'),
	description = list(
		title = 'Create packages from R-code directly',
		# version to be documented in news section
		#version = '0.1-0',
		author = 'Stefan Böhringer <r-packages@s-boehringer.org>',
		description = 'This package simplifies package generation by automating the use of `devtools` and `roxygen`. It also makes the development workflow more efficient by allowing ad-hoc development of packages. Use `?"package-package"` for a tutorial.',
		depends = c('roxygen2', 'devtools'),
		suggests = c('jsonlite', 'yaml'),
		news = "0.3-1	bug fix for missing files\n0.3-0	Beta, self-contained\n0.2-0	Alpha version\n0.1-0	Initial release"
	),
	git = list(
		readme = '## Installation\n```{r}\nlibrary(devtools);\ninstall_github("sboehringer/package")\n```\n',
		push = F,
		pushOnNewVersion = T,
		remote = 'https://github.com/sboehringer/package.git'
	)
);

#__PACKAGE_DOC__
# This package allows you to create a fully-fledged R-package from a single R-file reducing the added work-load for maintaining a package to a minimum. Depending on the project, collections of files can be used and configuration can be seperated into a stand-alone configuration file, providing full flexibility. It can also handle git interaction. This package is created with itself and you can look at the single R-file `Rpackage.R` for a self-referring example.
#
# @seealso {createPackage()} for starting the main workflow
#__PACKAGE_DOC_END__

packageDocPrefix = "# This is package `%{name}s`\n#\n# %{title}s\n#\n# @details\n# %{description}s\n";
#packageDocPrefix = "# This is package `%{name}s`\n#\n# @details\n# %{description}s\n#\n";
packageReadmeTemplate = "# R-package `%{PACKAGE_NAME}s`, version %{VERSION}s\n%{README}s\n# Description\n%{DESCRIPTION}s";

packageDescTemplate = "Package: %{PACKAGE_NAME}s\nType: %{TYPE}s\nTitle: %{TITLE}s\nVersion: %{VERSION}s\nDate: %{DATE}s\nAuthor: %{AUTHOR}s\nMaintainer: %{MAINTAINER}s\nDescription: %{DESCRIPTION}s\nLicense: %{LICENSE}s\nEncoding: %{ENCODING}s\nDepends: %{DEPENDS}s\nCollate: %{COLLATE}s\nSuggests: %{SUGGESTS}s\n";

packageInterpolationDict = function(o, debug = F) {
	if (debug) cat(templ);
	d = o$description;
	vars = list(
		PACKAGE_NAME = o$name,
		TYPE = firstDef(d$type, 'Package'),
		TITLE = d$title,
		VERSION = firstDef(d$version, Regexpr('\\S+', d$news)[[1]], '0.1-0'),
		DATE = firstDef(d$date, format(Sys.time(), "%d-%m-%Y")),
		AUTHOR = firstDef(d$author, 'anonymous'),
		MAINTAINER = firstDef(d$maintainer, d$author, 'anonymous'),
		DESCRIPTION = firstDef(d$description, ''),
		LICENSE = firstDef(d$license, 'LGPL'),
		ENCODING = firstDef(d$encoding, 'UTF-8'),
		COLLATE = circumfix(join(o$files, "\n    "), pre = "\n    "),
		DEPENDS = circumfix(join(d$depends, ",\n    "), pre = "\n    "),
		SUGGESTS = circumfix(join(d$suggests, ",\n    "), pre = "\n    "),
		README = firstDef(o$git$readme, '')
	);
	if (debug) print(vars);
	return(vars);
}
packageInterpolateVars = function(o, templ, debug = F) {
	if (debug) cat(templ);
	vars = packageInterpolationDict(o, debug);
	return(with(vars, Sprintf(templ)));
}
packageDescription = function(o, debug = F) {
	templ = firstDef(o$descriptionTemplate, packageDescTemplate);
	return(packageInterpolateVars(o, templ, debug));
}

gitOptionsDefault = list(doPull = F, doPush = F);
gitActions = function(o, packagesDir, debug, gitOptions = gitOptionsDefault) {
	gitOptions = merge.lists(gitOptionsDefault, gitOptions);
	i = packageInterpolationDict(o, debug);
	pdir = Sprintf('%{packagesDir}s/%{name}s', o);
	if (gitOptions$doPull) System(Sprintf('cd %{pdir}q ; git pull'), 2);

	readme = packageInterpolateVars(o, firstDef(o$git$readmeTemplate, packageReadmeTemplate));
	writeFile(Sprintf('%{pdir}s/README.md'), readme);
	# initialize git
	if (!file.exists(with(o, Sprintf('%{packagesDir}s/%{name}s/.git')))) {
		System(Sprintf('cd %{pdir}q ; git init'), 2);
	}
	System(Sprintf('cd %{pdir}q ; git add --all'), 2);
	System(with(i, Sprintf('cd %{pdir}q ; git commit -a -m "Commit for onward development of version %{VERSION}s"')), 2);
	tags = System(Sprintf('cd %{pdir}q ; git tag'), 2, return.output = T)$output;
	# tag new version
	newVersion = F;
	if (length(Regexpr(Sprintf('\\Q%{VERSION}s\\E', i), tags)[[1]]) == 0) {
		System(with(i, Sprintf('cd %{pdir}q ; git tag %{VERSION}s')));
		newVersion = T;
	}
	# remote
	if (notE(o$git$remote)) {
		remotes = System(Sprintf('cd %{pdir}q ; git remote -v'), 2, return.output = T)$output;
		if (remotes == '' && o$git$remote != '')
			System(Sprintf('cd %{pdir}q ; git remote add origin %{remote}s', o$git), 2);
		if (o$git$pushOnNewVersion && newVersion || gitOptions$doPush)
			System(Sprintf('cd %{pdir}q ; git push -u origin master ; git push origin %{VERSION}s', i), 2);
	}
}

createPackageWithConfig = function(o, packagesDir = '~/src/Rpackages',
	doInstall = FALSE, debug = F, gitOptions = list()) {
	if (debug) print(o);

	i = packageInterpolationDict(o, debug);
	pdir = Sprintf('%{packagesDir}s/%{name}s', o);
	packageDir = Sprintf('%{packagesDir}s/%{name}s', o);
	# <p> folders
	Dir.create(Sprintf('%{pdir}s'));
	Dir.create(Sprintf('%{pdir}s/R'));

	# <p> copy R files
	#src = Sprintf('%{dir}s/%{files}s', dir = o$dir, files = o$files, sprintf_cartesian = T);
	src = Sprintf('%{dir}s/%{files}s', o, sprintf_cartesian = T);
	dest = Sprintf('%{packageDir}s/R/');
	LogS(2, 'Copying files: %{f}s -> %{dest}s', f = join(src, ', '));
	File.copy(src, dest, symbolicLinkIfLocal = F, overwrite = T);
	# <p> extract package documentation
	doc = sapply(src, function(f)
		Regexpr('(?s)(?<=#__PACKAGE_DOC__\\n).*?(?=#__PACKAGE_DOC_END__\\n)', readFile(f))
	);
	# conflicts
	Ndoc = length(which(sapply(doc, nchar) > 0));
	if (Ndoc > 1) stop('More than one package documentation files/sections found');
	if (Ndoc == 1) {
		if (any(sapply(src, function(f)splitPath(f)$file) == Sprintf('%{name}s.R', o)))
			stop(Sprintf('%{name}s.R should contain package documentation which is also given elsewhere. %{name}s.R will be overwritten so that it cannot be used as an input file.', o));
		# substitute in fields from configuration [description]
		#doc0 = paste0(packageDocPrefix, join(doc, ''), "\n\"_PACKAGE\"\n");
		doc0 = paste0(packageDocPrefix, unlist(doc), "\n\"_PACKAGE\"\n");
		doc1 = Sprintf(doc0, o$description, name = o$name);
		doc2 = gsub("(^#)|((?<=\n)#)", "#'", doc1, perl = T);
		print(doc2);
		writeFile(Sprintf('%{pdir}s/R/%{name}s.R', o), doc2);
		o$files = c(Sprintf('%{name}s.R', o), o$files);	# documentation file to list of files
	}
	# <p> update NEWS file
	writeFile(with(o, Sprintf('%{pdir}s/NEWS')), firstDef(o$news, '0.1-0	Initial release'));
	writeFile(with(o, Sprintf('%{pdir}s/DESCRIPTION')), packageDescription(o));

	# <p> roxigen2
	Library('devtools');
	#document(packageDir, roclets = c('namespace', 'rd'));
	document(packageDir, roclets = c('collate'));

	# <p> git
	if (notE(o$git)) gitActions(o, packagesDir, debug, gitOptions);

	# <p> install
	if (doInstall) Install_local(Sprintf('%{packageDir}s'), upgrade = 'never');

	return(o);
}

probeDefinition = function(desc, dir = NULL) {
	path = Sprintf('%{pre}s%{file}s', pre = circumfix(dir, '/'), file = desc[1]);
	sp = splitPath(path);
	o = switch(sp$ext,
		# <!> assume unique is stable
		R = ({
			myEnv = new.env();
			Source(desc, local = myEnv);
			def = get('packageDefinition', envir = myEnv);
			def$files = unique(c(def$files, desc)); def }),
		plist = propertyFromStringExt(readFile(path)),
		json = ({ Library('jsonlite'); read_json(path) }),
		yaml = ({ Library('yaml'); read_yaml(path) })
	);
	o$dir = firstDef(dir, sp$dir);
	return(o);
}

#' Create package from vector of source files and single configuration
#' 
#' This function creates a package dir, runs documentation generation using roxygen and optionally installs the package. It can also update via git and manage version numbers. In a minimal configuration, a single file is sufficient to create a fully documented R package.
#' 
#' @alias createPackageWithConfig
#' @param packageDesc path to the configuration file (R, extended plist format)
#' @param packageDir folder in which the folder structure of the package is written
#' @param doInstall flag to indicate whether the package should also be installed
#' @section This function creates a valid R package folder with DESCRIPTION, LICENSE and NEWS files.
#'	All R-files listed are copied to this directory and documentation is created by  
#'	running the \code{devtools::document} function on this folder. details: \itemize{
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
#' @export createPackage
createPackage = function(packageDesc, packagesDir = '~/src/Rpackages',
	dir = NULL, doInstall = FALSE, gitOptions = list()) {
	packageDef = probeDefinition(packageDesc, dir);
	#print(packageDef);
	return(createPackageWithConfig(packageDef, packagesDir, doInstall, gitOptions = gitOptions));
}
