classdef CustomDisplayTest < matlab.unittest.TestCase
% CUSTOMDISPLAYTEST
%
% Description:
%   Tests custom displays for lack of errors (not sure there is any other
%   way to test the custom display output)
%
% Parent:
%    matlab.unittest.TestCase
%
% Use:
%   result = runtests('CustomDisplayTest.m')
%
% See also:
%   runAODataTestSuite

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

%#ok<*MANU> 

    methods (Test)
        function Parameters(testCase)
            paramObj = aod.util.Parameters();
            disp(paramObj);
            paramObj('Param1') = 1;
            paramObj('Param2') = 2;
            disp(paramObj);
        end

        function ParameterManager(testCase)
            PM = aod.util.ParameterManager();
            disp(PM);

            PM.add('Wavelength', [], [], 'Description');
            PM.add('Bandwidth', 20, @isnumeric, 'Description');
            disp(PM);
        end

        function DatasetManager(testCase) 
            cEXPT = ToyExperiment(false);
            DM = aod.util.DatasetManager.populate(cEXPT);
            disp(DM);
        end

        function HierarchyDisplay(testCase)
            cEXP = ToyExperiment(false);
            aod.util.displayHierarchy(cEXP);
        end
    end
end