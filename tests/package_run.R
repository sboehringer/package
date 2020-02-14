# This runs tests `package`
#testmeEnvInit('RtestsExpectations', logger = print);
library('testme');
print(testmeFileSingle('package.R', 'RtestsExpectations', useGit = FALSE, logger = print));
