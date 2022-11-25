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
% -------------------------------------------------------------------------

%#ok<*MANU> 

    properties
        EXPT
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            testCase.EXPT = loadExperiment('ToyExperiment.h5');
        end
    end

    methods (Test)
        function testParameters(testCase)
            paramObj = aod.util.Parameters();
            disp(paramObj);
            paramObj('Param1', 1);
            paramObj('Param2', 2);
            disp(paramObj);
        end
    end
end