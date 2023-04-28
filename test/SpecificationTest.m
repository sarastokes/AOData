classdef SpecificationTest < matlab.unittest.TestCase
% Tests specification of AOData subclasses
%
% Description:
%   Tests templates for specifying AOData subclasses
%
% Parent:
%    matlab.unittest.TestCase
%
% Use:
%   result = runtests('SpecificationTest.m')
%
% See also:
%   runAODataTestSuite

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    methods (Test, TestTags="Property")
        function PropertySpecification(testCase)
            prop = aod.util.templates.PropertySpecification("Test");
            prop.Class = "duration,double";
            testCase.verifyEqual(numel(prop.Class), 2);

            testCase.verifyError(...
                @() set(prop, "Class", "badclass"),...
                "PropertySpecification:InvalidClassName")
        end

        function ExpectedDataset(testCase)
            ED = aod.util.templates.ExpectedDataset("Test",...
                "double,duration", [], {@isnumeric},...
                "This is a test class", "seconds");
            testCase.verifyEqual(numel(ED.ClassName), 2);

            testCase.verifyError(...
                @()set(ED, "Validation", "double"),...
                "MATLAB:validation:UnableToConvert");
            testCase.verifyError(...
                @()set(ED, "Class", "badclass"),...
                "parseClassName:InvalidClass");
        end

        function DatasetManager(testCase)
            % Empty DatasetManager
            DM0 = aod.util.DatasetManager();
            testCase.verifyEqual(DM0.Count, 0);
            testCase.verifyEmpty(DM0.list());
            % Add a parameter
            DM0.add('TestParam', "double", 0, {@isnumeric},...
                "This is a test parameter", "seconds");
            testCase.verifyEqual(DM0.Count, 1);
        end

        function PopulatedDatasetManager(testCase)
            % Populated DatasetManager
            cEXPT = ToyExperiment(false);
            DM = aod.util.DatasetManager.populate(cEXPT);
            testCase.verifyEqual(DM.Count, 12);
            testCase.verifyNumElements(DM.list, 12);

            % Remove a parameter
            DM.remove('Code');
            testCase.verifyEqual(DM.Count, 11);

            % Clear all parameters
            DM.clear();
            testCase.verifyEqual(DM.Count, 0);
        end
    end
end 