classdef FermatFactorTest < matlab.unittest.TestCase
    methods (Test)
        function small(testCase)
            for x = 1:2024
                testCase.assertEqual(FermatFactor(x), factor(x), "Failed for: " + x);
            end
        end

        function small2(testCase)
            for x = 100000:100100
                testCase.assertEqual(FermatFactor(x), factor(x), "Failed for: " + x);
            end
        end

        function medium(testCase)
            testCase.assertEqual(FermatFactor(1415235137), factor(1415235137));
            testCase.assertEqual(FermatFactor(2345678917), 2345678917);
        end

        function medium2(testCase)
            start = 20000000;
            stop = start + 10;
            for x = start:stop
                testCase.assertEqual(FermatFactor(x), factor(x), "Failed for: " + x);
            end
        end
    end
end
