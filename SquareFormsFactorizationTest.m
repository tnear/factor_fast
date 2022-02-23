% Regression and performance tests for Shanks's square forms factorization
classdef SquareFormsFactorizationTest < matlab.unittest.TestCase
    properties (TestParameter)
        number = {2322, 8587, 11111, 18885, 57113, 65536, 65537, single(510510), ...
            988193, 2385210, 3636679, 4558849, 5214317, flintmax('single'), ...
            868153483, 6469693230, flintmax};
    end

    methods (Test)
        function smallNumbers(testCase)
            for x = 0:1000
                testCase.assertEqual(SquareFormsFactorization(x), factor(x));
            end
        end

        function smallInts(testCase)
            for x = int32(0):700
                testCase.assertEqual(SquareFormsFactorization(x), factor(x));
            end
        end

        function numbers(testCase, number)
            testCase.assertEqual(SquareFormsFactorization(number), factor(number), "Failed for: " + number);
        end

        function tofix(testCase)
            %num = uint64(...);
            %testCase.verifyEqual(SquareFormsFactorization(num), uint64(factor(sym(num))));
        end

        function large(testCase)
            N = int64(11111111111111111);
            testCase.assertEqual(SquareFormsFactorization(N), factor(N));

            num = int64(9223372036854775806);
            testCase.assertEqual(SquareFormsFactorization(num), int64(factor(sym(num))));

            num = uint64(18446744073709551614);
            testCase.assertEqual(SquareFormsFactorization(num), uint64(factor(sym(num))));
        end

        function cannotFactorDueToOverflow(testCase)
            testCase.assertEmpty(SquareFormsFactorization(int64(9223372036854775771)));
            testCase.assertEmpty(SquareFormsFactorization(uint64(18446744073709551603)));
            testCase.assertEmpty(SquareFormsFactorization(uint64(18446744073708200102)));
        end

        function perf1(testCase)
            num = int64(11111111111111111);
            tic;
            factor(num);
            factor(num);
            t1 = toc;
            t1 = t1/2;
            t2 = timeit(@() SquareFormsFactorization(num));
            expPerfGain = 10.7;
            testCase.log(matlab.unittest.Verbosity.Terse, string("Act: " + t1/t2 + ", Exp: " + expPerfGain));
            testCase.verifyGreaterThan(t1/t2, expPerfGain);
        end

        function perf2(testCase)
            num = int64(9223372036854775806);
            sNum = sym(num);
            % time sym/factor
            t1 = timeit(@() factor(sNum));
            numTrials = 2;
            tic;
            for x = 1:numTrials
                SquareFormsFactorization(num);
            end
            t2 = toc;
            t2 = t2/numTrials;
            % Note: althrough symbolic/factor is faster than SFF, 
            % SFF is about 21x faster than builtin factor()
            expPerfGain = .024;
            testCase.log(matlab.unittest.Verbosity.Terse, string("Act: " + t1/t2 + ", Exp: " + expPerfGain));
            testCase.verifyGreaterThan(t1/t2, expPerfGain);
        end

        function findDiff(testCase)
            % correct through 8000000
            for x = 8000000:8000001
                if mod(x, 50000) == 0
                    disp(x);
                end
                f1 = SquareFormsFactorization(x);
                f2 = factor(x);
                testCase.verifyEqual(f1, f2, "Failed for: " + x);
            end

            %msgbox Done!;
        end
    end
end
