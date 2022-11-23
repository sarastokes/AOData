
clear p1 p2 p3 p4 p5 prevPWD 
clear reportFormat reportDir suite runner aoDir baseDir results

prevPWD = pwd();

import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoverageReport

baseDir = getpref('AOData', 'BasePackage');
cd(fullfile(baseDir, 'test'));

reportDir = fullfile(baseDir, 'test', 'coverage_report');
reportFormat = CoverageReport(reportDir);

suite = testsuite(pwd);
runner = testrunner("textoutput");

% Folders for code coverage reports
aodDir = fullfile(baseDir, 'src', '+aod');
p1 = CodeCoveragePlugin.forFolder(fullfile(aodDir, '+core'),...
   'Producing', CoverageReport(fullfile(reportDir, 'core')));
runner.addPlugin(p1);
p2 = CodeCoveragePlugin.forFolder(fullfile(aodDir, '+persistent'),...
   'Producing', CoverageReport(fullfile(aodDir, 'persistent')));
runner.addPlugin(p2);
p3 = CodeCoveragePlugin.forFolder(fullfile(aodDir, '+h5'),...
   'Producing', CoverageReport(fullfile(aodDir, 'h5')));
runner.addPlugin(p3);
p4 = CodeCoveragePlugin.forFolder(fullfile(aodDir, '+util'),...
   'Producing', CoverageReport(fullfile(aodDir, 'util')));
runner.addPlugin(p4);
p5 = CodeCoveragePlugin.forFolder(fullfile(aodDir, '+builtin'),...
   'Producing', CoverageReport(fullfile(aodDir, 'builtin')));
runner.addPlugin(p5);

results = runner.run(suite);

cd(prevPWD);
