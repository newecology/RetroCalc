function testDataFolder = testDataRoot()
% Returns the path to the testdata folder

thisFilePath = mfilename('fullpath');
testRootPath = fileparts(fileparts(thisFilePath));

testDataFolder = fullfile(testRootPath, "testdata");

