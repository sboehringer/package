#
#	Rpackage.R
#Thu Oct 17 16:52:03 CEST 2019

packageDefinition = list(
	name = 'package',
	files = c('Rmeta.R', 'Rdata.R', 'Rsystem.R', 'Rfunctions.R', 'RpropertyList.R'),
	instFiles = list(Rscripts = 'Dev/pkg-minimal.R'),
	testing = list(
		doInstall = TRUE,
		tests = c('RtestsPackages/package/package.R')
	),
	description = list(
		title = 'Create packages from R-code directly',
		# version to be documented in news section
		#version = '0.1-0',
		author = 'Stefan B\uf6hringer <r-packages@s-boehringer.org>',
		description = 'This package simplifies package generation by automating the use of `devtools` and `roxygen`. It also makes the development workflow more efficient by allowing ad-hoc development of packages. Use `?"package-package"` for a tutorial or visit the project wiki (belonging to the source repository).',
		depends = c('roxygen2', 'devtools', 'methods'),
		suggests = c('testme', 'jsonlite', 'yaml', 'knitr'),
		enhances = c(),
		systemrequirements = c(),
		news = "0.11-4	noGit option for checkPackage\n0.11-3	Bug fix Windows support\n0.11-2	Bug fix\n0.11-1	Removed shell constructs in system calls\n0.11-0	Windows support\n0.10-0	Support for enhances, SystemRequirements in NAMESPACE\n0.9-0	Finished vignette. Clean test. RC1\n0.8-1	Bug fix automatic dependency addition.\n0.8-0	Vignette building finished. Project vignette in progress.\n0.7-0	Vignette building. Started vignette for package `package`\n0.6-0	Clean CRAN check\n0.5-1	Resolved documentation\n0.5-0	Error free CRAN check. Warnings left.\n0.4-4	bugfix NAMESPACE generation\n0.4-3	`createPackage` fully documented.\n0.4-2	More documentation\n0.4-1	Bug fix NEWS file\n0.4-0	Self-contained example\n0.3-1	bug fix for missing files\n0.3-0	Beta, self-contained\n0.2-0	Alpha version\n0.1-0	Initial release",
		license = 'LGPL-2',
		vignettes = "vignettes/vignette-package.Rmd"
	),
	git = list(
		readme = '## Installation\n```{r}\nlibrary(devtools);\ninstall_github("sboehringer/package")\n```\n',
		push = F,
		pushOnNewVersion = T,
		remote = 'https://github.com/sboehringer/package.git'
	)
);
# Imports
#' @import methods
#' @import roxygen2
#' @import devtools
#' @importFrom "stats" "as.formula" "median" "model.matrix" "na.omit" "runif" "setNames" "optimize" "sd"
#' @importFrom "utils" "read.table" "recover" "write.table"
globalVariables(c('valueMapperStandard', 'read_yaml', 'read_json'))

#__PACKAGE_DOC__
# This package allows you to create a full-fledged R-package from a single R-file reducing the added work-load for maintaining a package to a minimum. Depending on the project, collections of files can be used and configuration can be seperated into a stand-alone configuration file, providing full flexibility. It can also handle git interaction. This package is created with itself and you can look at the single R-file `Rpackage.R` for a self-referring example.
# The package contains a self-contained package example defined in the single R-file \code{pkg-minimal.R} which can be inspected and installed as in the example below.
# @examples
# \dontrun{
#  file.show(system.file('Rscripts/pkg-minimal.R', package = 'package'))
#  createPackage(system.file('Rscripts/pkg-minimal.R', package = 'package'))
# }
# @seealso {createPackage()} for starting the main workflow
#__PACKAGE_DOC_END__

packageDocPrefix = "# This is package `%{name}s`\n#\n# %{title}s\n#\n# @details\n# %{description}s\n";
#packageDocPrefix = "# This is package `%{name}s`\n#\n# @details\n# %{description}s\n#\n";
packageReadmeTemplate = "# R-package `%{PACKAGE_NAME}s`, version %{VERSION}s\n%{README}s\n# Description\n%{DESCRIPTION_MD}s";

packageDescTemplate = "Package: %{PACKAGE_NAME}s\nType: %{TYPE}s\nTitle: %{TITLE}s\nVersion: %{VERSION}s\nDate: %{DATE}s\nAuthor: %{AUTHOR}s\nMaintainer: %{MAINTAINER}s\nDescription: %{DESCRIPTION}s\nLicense: %{LICENSE}s\nEncoding: %{ENCODING}s\nDepends: %{DEPENDS}s\nCollate: %{COLLATE}s\nSuggests: %{SUGGESTS}s\nEnhances: %{ENHANCES}s\nSystemRequirements: %{SYSTEMREQUIREMENTS}s\n%{ADDITIONS}s";

packageInterpolationDict = function(o, debug = F) {
	additions = '';
	if (length(o$description$vignettes) > 0) {
		o$description$suggests = unique(c(o$description$suggests, c('knitr', 'rmarkdown')));
		additions = paste0(additions,  "VignetteBuilder: knitr\n");
	}
	d = o$description;
	vars = list(
		PACKAGE_NAME = o$name,
		TYPE = firstDef(d$type, 'Package'),
		TITLE = d$title,
		VERSION = o$version,	# determined in probeDefinition
		DATE = firstDef(d$date, format(Sys.time(), "%Y-%m-%d")),
		AUTHOR = firstDef(d$author, 'anonymous'),
		MAINTAINER = firstDef(d$maintainer, d$author, 'anonymous'),
		DESCRIPTION = firstDef(d$description, ''),
		LICENSE = firstDef(d$license, 'LGPL-2'),
		ENCODING = firstDef(d$encoding, 'UTF-8'),
		COLLATE = circumfix(join(sapply(o$files, function(f)splitPath(f)$file), "\n    "), pre = "\n    "),
		DEPENDS = circumfix(join(d$depends, ",\n    "), pre = "\n    "),
		SUGGESTS = circumfix(join(d$suggests, ",\n    "), pre = "\n    "),
		ENHANCES = circumfix(join(d$enhances, ",\n    "), pre = "\n    "),
		SYSTEMREQUIREMENTS = circumfix(join(d$systemrequirements, ",\n    "), pre = "\n    "),
		README = firstDef(o$git$readme, ''),
		ADDITIONS = additions
	);
	# <!> code w/ {}'s
	vars$DESCRIPTION_MD = gsub("\\\\code[{](.*?)[}]", "`\\1`", vars$DESCRIPTION, perl = T);
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
	if (debug) cat(templ);
	return(packageInterpolateVars(o, templ, debug));
}

gitOptionsDefault = list(doPull = F, doPush = F);
gitActions = function(o, packagesDir, debug, gitOptions = gitOptionsDefault) {
	gitOptions = merge.lists(gitOptionsDefault, gitOptions);
	i = packageInterpolationDict(o, debug);
	pdir = Sprintf('%{packagesDir}s/%{name}s', o);
	if (gitOptions$doPull) System('git pull', 2, wd = pdir);

	readme = packageInterpolateVars(o, firstDef(o$git$readmeTemplate, packageReadmeTemplate));
	writeFile(Sprintf('%{pdir}s/README.md'), readme);
	# initialize git
	if (!file.exists(with(o, Sprintf('%{packagesDir}s/%{name}s/.git')))) {
		System('git init', 2, wd = pdir);
	}
	System('git add --all', 2, wd = pdir);
	System(with(i, Sprintf('git commit -a -m "Commit for onward development of version %{VERSION}s"')), 2, wd = pdir);
	tags = System('git tag', 2, wd = pdir, return.output = T)$output;
	# tag new version
	newVersion = F;
	if (length(Regexpr(Sprintf('\\Q%{VERSION}s\\E', i), tags)[[1]]) == 0) {
		System(with(i, Sprintf('git tag %{VERSION}s')), wd = pdir);
		newVersion = T;
	}
	# remote
	if (notE(o$git$remote)) {
		remotes = System('git remote -v', 2, wd = pdir, return.output = T)$output;
		if (remotes == '' && o$git$remote != '')
			System(Sprintf('git remote add origin %{remote}s', o$git), 2, wd = pdir);
		if (o$git$pushOnNewVersion && newVersion || gitOptions$doPush) {
			System('git push -u origin master', 2, wd = pdir);
			System(Sprintf('git push origin %{VERSION}s', i), 2, wd = pdir);
		}
	}
}

installTests = function(o, packageDir, loadTestMe = FALSE, asCran = FALSE) {
	#if (loadTestMe) requireNamespace('testme');	# <i> trick shiny not to install testme
	if (is.null(rget('installPackageTests', NULL))) {
		Log('Package testme not available, skipping tests creation', 1);
		return(NULL);
	}
	#testme::installPackageTests(packageDir, o$testing$tests, createReference = TRUE, asCran);
	installPackageTests(packageDir, o$testing$tests, createReference = TRUE, asCran);

}

# <N> values are interpolated by Sprintf, '%' -> '%%'
vignetteDefaultKeys = list(
	title = 'How to use %{packageName}s',
	date = '"`r Sys.Date()`"',
	vignette =  ">\n  %%\\VignetteIndexEntry{%{file}s}\n  %%\\%{Vignette}sEngine{knitr::rmarkdown}\n  %%\\%{Vignette}sEncoding{UTF-8}",
	output = "rmarkdown::html_vignette"
	#output = "\n  html_document:\n    keep_md: TRUE"
	#output = "\n  rmarkdown::html_vignette:\n    keep_md: TRUE"
);

popcharif = function(s, char = "\n") {
	N = nchar(s);
	if (N == 0) return(s);
	if (substr(s, N, N) == char) return(substr(s, 1, N -1));
	return(s);
}

installVignette = function(name, path, o, packageDir, noGit = F) {
	name = splitPath(name)$base;	# normalize, allow path as name
	v = readFile(path);
	cat(v);
	m0 = unlist(Regexpr("(?six)^---\\n+
	((?:
		(?:\\S*)[\\t ]*:[\\t ]*
		(?:[^\\n]+\\n (?:[ \\t]+[^\\n]+\\n)* ) \\n*
	)+)---\\n(.*)", v, captures = T, concatMatches = F));
	dictR0 = Regexpr("(?six)
		(?<key>[a-z]\\S*)[\\t ]*:[\\t ]*
		(?<value> [^\\n]+\\n (?:[ \\t]+[^\\n]+\\n)* ) \\n*
	", m0[1], captures = T, concatMatches = F, global = T);
	dictR1 = list.transpose(dictR0[[1]]);
	dictR2 = listKeyValue(list.kp(dictR1, 'key'), sapply(list.kp(dictR1, 'value'), popcharif));
	dict = merge.lists(vignetteDefaultKeys, list(
		author = o$description$author,
		packageName = o$name,
		file = Sprintf('%{name}s.Rmd')
	), dictR2);
	meta = Sprintf(join(nelapply(dict, function(n, e)Sprintf('%{n}s: %{e}s')), "\n"),
		c(dict, list(Vignette = 'Vignette')));	#<!> hack to avoid warning
	vignette = m0[2];
	Rmd = Sprintf('---\n%{meta}s\n---\n%{vignette}s');
	writeFile(Sprintf('%{packageDir}s/vignettes/%{name}s.Rmd'), Rmd, mkpath = T);
	if (!noGit) {
		ignore = Sprintf('%{packageDir}s/vignettes/.gitignore');
		if (!file.exists(ignore)) writeFile(ignore, "vignettes/*.html\nvignettes/*.R\n");
	}
}

build_vignettes_to_md = function(o, packageDir) {
	nelapply(o$description$vignettes, function(name, p){
		name = splitPath(name)$base;
		knitr::knit(
			Sprintf('%{packageDir}s/vignettes/%{name}s.Rmd'),
			Sprintf('%{packageDir}s/doc/%{name}s.md')
		);
	});
}

installVignettes = function(o, packageDir, keep_md = TRUE) {
	vignettes = o$description$vignettes;
	if (!is.list(vignettes)) o$description$vignettes = listKeyValue(vignettes, vignettes);
	nelapply(o$description$vignettes, installVignette, o = o, packageDir = packageDir);
	# keep_md = T does not seem to work, even in conjunction with a markdown parameter -> workaround
	build_vignettes(packageDir, keep_md = FALSE);
	if (keep_md) build_vignettes_to_md(o, packageDir);
}

#doInstall = FALSE, debug = F, gitOptions = list(), noGit = F, lib = NULL, tarDir = packagesDir)
createPackageWithConfig = function(o, packagesDir = '~/src/Rpackages',
	doInstall = FALSE, debug = F, gitOptions = list(), noGit = F, lib = NULL, tarDir = tempdir(),
	asCran = FALSE) {
	if (debug) print(o);

	i = packageInterpolationDict(o, debug);
	pdir = Sprintf('%{packagesDir}s/%{name}s', o);
	packageDir = Sprintf('%{packagesDir}s/%{name}s', o);

	# <p> folders
	Dir.create(Sprintf('%{pdir}s'));
	Dir.create(Sprintf('%{pdir}s/R'));

	# <p> copy R files
	#src = Sprintf('%{dir}s/%{files}s', dir = o$dir, files = o$files, sprintf_cartesian = T);
	#src = Sprintf('%{dir}s/%{files}s', o, sprintf_cartesian = T);
	src = sapply(o$files, function(f)if (splitPath(f)$isAbsolute) f else Sprintf('%{dir}s/%{f}s', o));
	dest = Sprintf('%{packageDir}s/R/');
	LogS(2, 'Copying files: %{f}s -> %{dest}s', f = join(src, ', '));
	File.copy(src, dest, symbolicLinkIfLocal = F, overwrite = T);

	# <p> copy files for inst sub-folder
	nelapply(o$instFiles, function(n, files) {
		dest = Sprintf('%{packageDir}s/inst/%{n}s');
		Dir.create(dest, recursive = T);
		LogS(2, 'Copying files: %{f}s -> %{dest}s', f = join(src, ', '));
		File.copy(files, dest, symbolicLinkIfLocal = F, overwrite = T);
	});

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
		#print(doc2);
		writeFile(Sprintf('%{pdir}s/R/%{name}s.R', o), doc2);
		o$files = c(Sprintf('%{name}s.R', o), o$files);	# documentation file to list of files
	}

	# <p> update NEWS file
	writeFile(with(o, Sprintf('%{pdir}s/NEWS')), firstDef(o$description$news, '0.1-0	Initial release'));
	writeFile(with(o, Sprintf('%{pdir}s/DESCRIPTION')), packageDescription(o));

	# <p> testing
	if (notE(o$testing) && o$testing$doInstall && !nif(o$testing$prevent))
		installTests(o, packageDir, asCran = asCran);
	# <p> roxigen2
	#Library(c('roxygen2', 'devtools'));
	#document(packageDir, roclets = c('namespace', 'rd'));
	#document(packageDir, roclets = c('rd'));
	#roxygenize(packageDir, roclets = c('rd'), clean = TRUE);
	roxygenize(packageDir, clean = TRUE);

	# <p> vignettes
	if (notE(o$description$vignettes)) installVignettes(o, packageDir);

	# <p> git
	if (!noGit && notE(o$git)) gitActions(o, packagesDir, debug, gitOptions);

	# <p> install
	if (doInstall) Install_local(Sprintf('%{packageDir}s'), upgrade = 'never', lib = lib, tarDir = tarDir);

	return(o);
}

packageDefFromPath = function(path) {
	myEnv = new.env();
	# <N> instead of Source: avoid RCurl dependency
	SourceLocal(path, local = myEnv);
	def = get('packageDefinition', envir = myEnv);
	# add definition file as first file <!> (no forward declarations)
	# <!> 30.9.2021 changed to last position to allow referencing
	def$files = unique(c(def$files, splitPath(path)$file));
	return(def);
}

probeDefinition = function(desc, dir = NULL) {
	path = Sprintf('%{pre}s%{file}s', pre = circumfix(dir, '/'), file = desc[1]);
	sp = splitPath(path);
	o = switch(sp$ext,
		# <!> assume unique is stable
		R = packageDefFromPath(desc[1]),
		plist = propertyFromStringExt(readFile(path)),
		json = ({ requireNamespace('jsonlite'); read_json(path) }),
		yaml = ({ requireNamespace('yaml'); read_yaml(path) })
	);
	o$dir = firstDef(dir, sp$dir);
	o$version = firstDef(o$description$version, Regexpr('\\S+', o$description$news)[[1]], '0.1-0');
	return(o);
}

packageTarOSOptions = list(Linux = '--overwrite', Windows = c());
checkPackage = function(packageDesc, packagesDir, asCran = TRUE, copyCranTarball = TRUE, clean = TRUE, noGit = FALSE)
	with (packageDesc, {
	checkDir = packageDir = Sprintf("%{packagesDir}s/%{name}s");
	packagesDirPrev = packagesDir;
	if (!noGit && file.exists(Sprintf("%{packageDir}s/.git"))) {
		packagesDir = tempdir();
		checkDir = Sprintf('%{packagesDir}s/%{name}s');
		# <i> move if exists
		if (file.exists(checkDir) && clean) {
			file.rename(checkDir, Sprintf('%{checkDir}s-%{i}d', i = as.integer(runif(1)*1e6)))
		}
		dir.create(checkDir, FALSE);
		#SystemS('cd %{packageDir}q ; git archive --format tar HEAD | ( cd %{checkDir}q ; tar xf - --exclude inst/doc --overwrite )', 2);
		#SystemS('cd %{packageDir}q ; git archive --format tar HEAD | ( cd %{checkDir}q ; tar xf - --overwrite )', 2);
		#SystemS('cd %{packageDir}q ; git archive --format tar HEAD | ( cd %{checkDir}q ; tar xf - --overwrite )', 2);
		# 		cmdGit = JoinCmds(Sprintf(c('cd %{packageDir}q', 'git archive --format tar HEAD')));
		# 		cmdTar = JoinCmds(Sprintf(c('cd %{checkDir}q', 'tar xf - --overwrite')));
		# 		SystemS('%{cmdGit}s | ( %{cmdTar}s )', 2);
		fArchive = tempfile();
		SystemS('git archive --format tar HEAD -o %{fArchive}q', 2, wd = packageDir);
		#SystemS('tar xf %{fArchive}q --overwrite', 2, wd = checkDir);
		untar(fArchive, exdir = checkDir, extras = packageTarOSOptions[[ Sys.info()['sysname'] ]]);
	}
	cran = if (asCran) '--as-cran' else '';
	# 	SystemS(JoinCmds(c(
	# 		'cd %{packagesDir}q',
	# 		'R CMD build %{name}q',
	# 		'R CMD check %{cran}s %{name}q_%{version}s.tar.gz'
	# 	)), 2);
	SystemS('R CMD build %{name}q', 2, wd = packagesDir);
	SystemS('R CMD check %{cran}s %{name}q_%{version}s.tar.gz', 2, wd = packagesDir);
	if (asCran && copyCranTarball) {
		from = Sprintf('%{packagesDir}s/%{name}q_%{version}s.tar.gz');
		to = Sprintf('%{packagesDirPrev}s/%{name}q_%{version}s-cran.tar.gz');
		File.copy(from, to, overwrite = T, symbolicLinkIfLocal = F, logLevel = 2);
	}
})

#' Create package from vector of source files and single configuration
#' 
#' This function creates a package dir, runs documentation generation using roxygen and optionally installs the package. It can also update via git and manage version numbers. In a minimal configuration, a single file is sufficient to create a fully documented R package.
#' 
#' @alias createPackageWithConfig
#' @param packageDesc path to the configuration file (R, extended plist format, json, yaml).
#'	If an R-file is provided, it is sourced in a seperate environment and needs to define the variable
#'	`packageDefinition`. This variable has to be a list which is further specified in the details below.
#'	If a propertyList/JSON/YAML-file is provided, they have to parse into a list corresponding to
#'	`packageDefinition`. Functions \code{propertyFromStringExt}, \code{read_json}, and \code{read_yaml} are
#'	used for parsing, coming from packages \code{package}, \code{jsonlite}, and \code{yaml}.
#' @param packagesDir folder in which the folder structure of the package is written
#' @param doInstall flag to indicate whether the package should also be installed
#' @param doCheck whether to run R CMD check --as-cran on the package
#' @param dir directory to search for package definition
#' @param gitOptions list with options for git interaction
#' @param noGit boolean to suppress git calls, overwrites other options
#' @param lib Path to package library as forwarded to \code{install.packages}
#' @param asCran boolean to indicate whether check should be including --as-cran
#'
#' @details This function creates a valid R package folder with DESCRIPTION, LICENSE and NEWS files.
#'	All R-files listed are copied to this directory and documentation is created by  
#'	running the \code{devtools::document} function on this folder.
#' The package is specified through a list coming from an R script or configuration file.
#'	The following elements control package generation. In this list \code{key1-key2} indicates a
#'	sublist-element, i.e. it stand for \code{packageDefinition[[key1]][[key2]]}.
#'	
#'	\itemize{
#'		\item{name: }{The name of the pacakge}
#'		\item{files: }{R-files to be put into the package. If an R-file is used for the configuration,
#'			it will automatically be include. This allows package definition through a single R-file.}
#'		\item{instFiles: }{Other files to be installed. This is a list, the names of which specify
#'			sub-folders in the \code{inst} sub-directory of the package. Values are character vectors
#'			specifying files to be put there.}
#'		\item{description: }{A sub-list with elements specifying the \code{DESCRIPTION} file of the package.}
#'		\item{description-title: }{The title of the help page 'package-myPackage' (myPackage is the name
#'			of the package) and the title fiedl in DESCRIPTION.}
#'		\item{description-author: }{The \code{Author} field in DESCRIPTION.
#'		\item{description-description: } The \code{Description} field in DESCRIPTION. The text is re-used
#'			for the package documentation as displayed by ?'package-myPackage' and is prepended to the 
#'			seperate package documentation. It is also inserted as a Description section of a Markdown file
#'			if git is used. This string should therefore not make use of roxygen/markdown markup.}
#'		\item{description-depends: }{A character vector with package dependencies.}
#'		\item{description-suggests: }{A character vector with package suggestions.}
#'		\item{description-news: }{A character vector with a single element containing the \code{NEWS}
#'			file of the package. It is assumed that a line starting with a non white space character
#'			indicates a new version. The version identifier is taken to be all characters until the
#'			first white space. Once a new version is detected, git actions might be triggered (see below).}
#'		\item{git: }{A sub-list specifying git behavior. If you do not
#'			want to use git, omit this entry from \code{packageDefinition}. If present, a git repository
#'			is created and maintained in the target folder. Default \code{git} settings for the package can be 
#'			overwritten using the  \code{gitOptions} argument.}
#'		\item{git-push: }{Logical, whether to push each commit, defaults to \code{FALSE}.}
#'		\item{git-pushOnNewVersion: }{Logical, whether to push each when a new release is created
#'			(see item \code{description-news}. Defaults to \code{TRUE}.
#'			A push is automatically performed, once a new release is created, irrespective of this setting.
#'			To suppress a push in these cases, push has to set to \code{FALSE} in the. }
#'		\item{git-readme: }{Character vector with single entry with the content of a readme file that is put
#'			as \code{README.md} into the package main folder. The description given under
#'			\code{description-description} is appended to this text.}
#'	}
#' @author Stefan Böhringer, \email{r-packages@@s-boehringer.org}
#' @seealso package-package
#' @keywords create package createPackage
#' @examples
#' 
#' packageDefinition = list(
#' 	name = 'pkg-minimal',
#' 	files = c(),
#'	instFiles = list(),
#' 	description = list(
#' 		title = 'Minimal R-package created with `package`',
#' 		# version to be documented in news section
#' 		#version = '0.1-0',
#' 		author = 'Stefan Böhringer <r-packages@s-boehringer.org>',
#' 		description = 'This appears in the package-documentaion, the markdown of the git-repository and in the package details.',
#' 		depends = c(),
#' 		suggests = c(),
#' 		license = 'LGPL',
#' 		news = "0.1-0	Initial release"
#' 	),
#' 	git = list(
#' 		readme = '## Installation\n```{r}\nlibrary(devtools);\ninstall_github("user/pkg-minimal")\n```\n',
#' 		push = FALSE,
#' 		pushOnNewVersion = FALSE
#' 	)
#' );
#'
#'
#' @export createPackage
createPackage = function(packageDesc, packagesDir = '~/src/Rpackages',
	dir = NULL, doInstall = FALSE, doCheck = T, gitOptions = list(), noGit = F, lib = NULL, asCran = FALSE) {
	packageDef = probeDefinition(packageDesc, dir);
	#print(packageDef);
	r = createPackageWithConfig(packageDef, packagesDir, doInstall,
		gitOptions = gitOptions, noGit = noGit,
		lib = lib, asCran = asCran
	);
	if (doCheck) checkPackage(packageDef, packagesDir, asCran, noGit = noGit);
	return(r);
}

#
#	<p> local development
#
SourcePackage = function(path) {
	def = packageDefFromPath(path);
	Source(def$files, locations = splitPath(path)$dir);
}

LibraryPackage = function(path, suggests = TRUE) {
	def = packageDefFromPath(path);
	Library(def$description$depends);
	if (suggests) Library(def$description$suggests);
}

SetupPackage = function(path, suggests = TRUE) {
	LibraryPackage(path, suggests = suggests);
	SourcePackage(path);
}
