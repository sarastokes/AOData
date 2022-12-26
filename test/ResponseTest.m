classdef ResponseTest < matlab.unittest.TestCase 

    properties 
        RESP0
        RESP1
        RESP2
        RESP3

        DATA1
        DATA2
    end

    methods (TestClassSetup)
        function createResponses(testCase)
            testCase.RESP0 = aod.core.Response('Scalar',...
                'Data', 0);
            
            testCase.DATA1 = [1 2 3];
            testCase.RESP1 = aod.core.Response('Resp1',...
                'Data', testCase.DATA1);
            
            testCase.DATA2 = [1 2 3; 4 5 6; 7 8 9];
            testCase.RESP2 = aod.core.Response('Resp2',...
                'Data', testCase.DATA2);
            
            testCase.RESP3 = aod.core.Response('Three',...
                'Data', 3);
        end
    end

    methods (Test)
        function Equals(testCase)
            testCase.verifyTrue(testCase.RESP3 == testCase.RESP3);
            testCase.verifyTrue(testCase.RESP3 == 3);
            testCase.verifyTrue(3 == testCase.RESP3);
        end

        function NotEqual(testCase)
            testCase.verifyTrue(testCase.RESP3 ~= testCase.RESP0);
            testCase.verifyTrue(testCase.RESP3 ~= 2);
        end

        function GreaterThanOrEqual(testCase)
            testCase.verifyTrue(testCase.RESP3 >= 3);
            testCase.verifyTrue(testCase.RESP3 >= 2);
            testCase.verifyTrue(3 >= testCase.RESP0);
            testCase.verifyTrue(testCase.RESP3 >= testCase.RESP0);
            testCase.verifyFalse(testCase.RESP0 >= testCase.RESP3);
        end

        function LessThanOrEqual(testCase)
            testCase.verifyTrue(testCase.RESP0 <= testCase.RESP3);
            testCase.verifyTrue(testCase.RESP3 <= testCase.RESP3);
        end

        function LessThan(testCase)
            testCase.verifyTrue(testCase.RESP0 < testCase.RESP3);
            testCase.verifyFalse(testCase.RESP3 < testCase.RESP3);
        end

        function GreaterThan(testCase)
            testCase.verifyTrue(testCase.RESP3 > testCase.RESP0);
            testCase.verifyFalse(testCase.RESP3 > testCase.RESP3);
        end

        function Plus(testCase)
            testCase.verifyEqual(testCase.RESP3 + 1, 4);
            testCase.verifyEqual(testCase.RESP3 + testCase.RESP3, 6);
        end

        function Minus(testCase)
            testCase.verifyEqual(testCase.RESP3 - 1, 2);
            testCase.verifyEqual(testCase.RESP3 - testCase.RESP3, 0);
            testCase.verifyEqual(6 - testCase.RESP3, 3);
        end

        function UMinus(testCase)
            testCase.verifyEqual(-testCase.RESP3, -3);
        end

        function Not(testCase)
            resp = aod.core.Response('Not', 'Data', [1 0]);
            testCase.verifyEqual(not(resp), [false, true]);
        end
    end

    methods (Test)
        function Transpose(testCase)
            testCase.verifyEqual(testCase.RESP1', [1 2 3]');
        end
    end

    methods (Test)
        function IsMissing(testCase)
            testCase.verifyFalse(ismissing(testCase.RESP0));
        end

        function Finite(testCase)
            infResp = aod.core.Response('Inf', 'Data', Inf);
            testCase.verifyFalse(isinf(testCase.RESP0));
            testCase.verifyTrue(isinf(infResp));

            testCase.verifyTrue(isfinite(testCase.RESP0));
            testCase.verifyFalse(isfinite(infResp));
        end
    end

    methods (Test)
        function Mean(testCase)
            testCase.verifyEqual(...
                mean(testCase.RESP1), mean(testCase.DATA1));
            testCase.verifyEqual(...
                mean(testCase.RESP2, 1), mean(testCase.DATA2, 1));
        end
    end
end