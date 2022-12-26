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

    methods (Test, TestTags=["Response", "Operators"])
        function Equals(testCase)
            testCase.verifyTrue(testCase.RESP3 == testCase.RESP3);
            testCase.verifyTrue(testCase.RESP3 == 3);
            testCase.verifyTrue(3 == testCase.RESP3);

            testCase.verifyFalse(isequal(testCase.RESP2, testCase.DATA2));
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
            testCase.verifyEqual(not(resp), [true, false]);
        end
    end

    methods (Test, TestTags=["Response", "Stats"])
        function Abs(testCase)
            resp = aod.core.Response('Test', 'Data', [-1 1]);
            testCase.verifyEqual(abs(resp), [1 1]);
        end

        function Mean(testCase)
            testCase.verifyEqual(...
                mean(testCase.RESP1), mean(testCase.DATA1));
            testCase.verifyEqual(...
                mean(testCase.RESP2, 1), mean(testCase.DATA2, 1));
        end

        function Median(testCase)
            testCase.verifyEqual(...
                median(testCase.RESP2, 1), median(testCase.DATA2, 1));
        end

        function Std(testCase)
            testCase.verifyEqual(...
                std(testCase.RESP2, [], 2), std(testCase.DATA2, [], 2));
        end

        function Sum(testCase)
            testCase.verifyEqual(...
                sum(testCase.RESP2, 2), sum(testCase.DATA2, 2));
        end

        function CumSum(testCase)
            testCase.verifyEqual(...
                cumsum(testCase.RESP2, 2), cumsum(testCase.DATA2, 2));
        end

        function Iqr(testCase)
            testCase.verifyEqual(...
                iqr(testCase.RESP2, 'all'), iqr(testCase.DATA2, 'all'));
        end

        function Quantile(testCase)
            testCase.verifyEqual(...
                quantile(testCase.RESP2, 3), quantile(testCase.DATA2, 3));
        end

        function Prctile(testCase)
            testCase.verifyEqual(...
                prctile(testCase.RESP2, 50), prctile(testCase.DATA2, 50));
        end
    end
end