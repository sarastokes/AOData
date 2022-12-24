classdef HdfTest < matlab.unittest.TestCase
    
    methods (Test)
        function PropertyHandling(testCase)
            obj = test.TestDevice();

            [dsetProps, attProps, abandonedProps] = ...
                aod.h5.getPersistedProperties(obj);

            % Ensure empty properties are not flagged for persistence
            testCase.verifyTrue(ismember('EmptyProp', abandonedProps));
            testCase.verifyFalse(ismember('EmptyProp', dsetProps));

            % Ensure dependent props are persisted unless hidden
            testCase.verifyTrue(ismember('DependentProp', dsetProps));
            testCase.verifyFalse(ismember('HiddenDependentProp', dsetProps));
        end
    end
end