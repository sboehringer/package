# This runs tests `package`
#testmeEnvInit('RtestsExpectations', logger = print);
library('testme');
print(testmeFileSingle('testme/package.R', 'testme/RtestsExpectations', useGit = FALSE, logger = print));
