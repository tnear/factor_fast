classdef PollardRhoTest < matlab.unittest.TestCase
    methods (Test)
        function t1(testCase)
            testCase.assertEqual(PollardRho(1), factor(1));
            testCase.assertEqual(PollardRho(2), factor(2));
            testCase.assertEqual(PollardRho(3), factor(3));
            testCase.assertEqual(PollardRho(4), factor(4));
            testCase.assertEqual(PollardRho(21), factor(21));
            testCase.assertEqual(PollardRho(8051), factor(8051));
            testCase.assertEqual(PollardRho(10403), factor(10403));
            testCase.assertEqual(PollardRho(10967535067), factor(10967535067));
        end

        function smallScalars(testCase)
            for x = 0:500
                testCase.assertEqual(PollardRho(x), factor(x), "Failed for: " + x);
            end
        end
    end
end
