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

    methods (Test, TestTags="Parameter")
        function ParameterNameSearch(testCase)
            import aod.util.ErrorTypes

            PM = aod.util.ParameterManager();
            PM.add('NewParam');

            % Search for parameter that doesn't exist
            p0 = PM.get('NewParam');
            testCase.verifyTrue(strcmp(p0.Name, "NewParam"));
            
            % Search for parameter that exists
            p1 = PM.getParam('BadParam', ErrorTypes.NONE);
            testCase.verifyEmpty(p1);
            testCase.verifyError(...
                @() PM.getParam('BadParam', ErrorTypes.ERROR),...
                "get:ParameterNotFound");
            testCase.verifyWarning(...
                @() PM.getParam('BadParam', ErrorTypes.WARNING),...
                "get:ParameterNotFound");
        end

        function ParameterAddition(testCase)
            PM = aod.util.ParameterManager();
        end

        function CoreEntityParameters(testCase)
            obj = aod.builtin.devices.BandpassFilter(510, 20);
            p = obj.expectedParameters.get('Bandwidth');
            testCase.verifyEqual(p.Name, 'Bandwidth');

            % Set/remove expected parameter
            obj.setParam('Bandwidth', 30);
            testCase.verifyEqual(obj.parameters('Bandwidth'), 30);
            obj.removeParam('Bandwidth');
            testCase.verifyTrue(obj.parameters.isKey('Bandwidth'));
            testCase.verifyEmpty(obj.parameters('Bandwidth'));

            % Set/remove adhoc parameter
            obj.setParam('RandomParam', true);
            obj.removeParam('RandomParam');
            testCase.verifyFalse(obj.parameters.isKey('RandomParam'));
        end
    end

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
            testCase.verifyEqual(numel(ED.Class), 2);

            testCase.verifyError(...
                @()set(ED, "Validation", "double"),...
                "MATLAB:validation:UnableToConvert");
            %testCase.verifyError(...
            %    @()set(ED, "Class", "badclass"),...
            %    "parseClassName:InvalidClass");
        end

        function DatasetManager(testCase)
            % Empty DatasetManager
            DM = aod.util.DatasetManager();
            testCase.verifyEqual(DM.Count, 0);
            testCase.verifyEmpty(DM.list());
            
            % Add a parameter
            DM.add('TestParam', "double", 0, {@isnumeric},...
                "This is a test parameter", "seconds");
            testCase.verifyEqual(DM.Count, 1);

            % Overwrite existing parameter
            testCase.verifyWarning(...
                @() DM.add('TestParam', 'double'), "add:OverwroteDataset");
            
            ED = aod.util.templates.ExpectedDataset("TestParam");
            testCase.verifyWarning(...
                @() DM.add(ED), "add:OverwroteDataset");
            
            warning('off', "add:OverwroteDataset");
            DM.add('TestParam', "double", 2, {@isnumeric},...
                "This is an overwritten test parameter", "seconds");
            testCase.verifyEqual(DM.Count, 1);
            ED = DM.get('TestParam');
            testCase.verifyEqual(ED.Default, 2);
            warning('on', "add:OverwroteDataset");
        end

        function PopulatedDatasetManager(testCase)
            % Populated DatasetManager
            cEXPT = ToyExperiment(false);
            DM = aod.util.DatasetManager.populate(cEXPT);
            testCase.verifyEqual(DM.Count, 4);
            testCase.verifyNumElements(DM.list, 4);

            % Remove a parameter
            DM.remove('epochIDs');
            testCase.verifyEqual(DM.Count, 3);

            % Clear all parameters
            DM.clear();
            testCase.verifyEqual(DM.Count, 0);
        end
    end
end 