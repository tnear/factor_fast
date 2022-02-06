% Basic regression and performance tests for factor_fast
classdef FactorTest < matlab.unittest.TestCase
    properties (TestParameter)
        nonScalars = {[], [1, 2], cell.empty};
        notPositiveInts = {1i, -1, 1.1, NaN, {1}, "1", -Inf};
        outOfRanges = {flintmax + 2, Inf, flintmax('single') + 3};
        sparseValues = {sparse(0), sparse(6), sparse(23), sparse(117)};
        dataTypes = {true, false, single(11), uint64(18), 'a'};
    end

    methods (Test)
        function nonScalar(testCase, nonScalars)
            testCase.assertError(@() factor_fast(nonScalars), "MATLAB:factor:NonScalarInput");
        end
        
        function notPositiveInt(testCase, notPositiveInts)
            testCase.assertError(@() factor_fast(notPositiveInts), "MATLAB:factor:InputNotPosInt");
        end

        function outOfRange(testCase, outOfRanges)
            testCase.assertError(@() factor_fast(outOfRanges), "MATLAB:factor:InputOutOfRange");
        end

        function smallScalars(testCase)
            for x = 0:800
                testCase.assertEqual(factor_fast(x), factor(x), "Failed for: " + x);
            end
        end

        function smallInts(testCase)
            for x = int32(0):800
                testCase.assertEqual(factor_fast(x), factor(x));
            end
        end

        function uint8(testCase)
            for x = uint8(0):255
                testCase.assertEqual(factor_fast(x), factor(x));
            end
        end

        function dataType(testCase, dataTypes)
            testCase.assertEqual(factor_fast(dataTypes), factor(dataTypes));
        end

        function sparseValue(testCase, sparseValues)
            testCase.assertEqual(factor_fast(sparseValues), factor(sparseValues));
        end

        function randInt32(testCase)
            nums = intmax("uint32");
            numElements = 600;
            nums = nums - uint32(randi(nums/2, [1 numElements]));
            for num = nums
                testCase.assertEqual(factor(num), factor_fast(num), "Failed for: " + num);
            end
        end

        function perfTiny1(testCase)
            expPerfGain = 8.8;
            measurePerf(testCase, 6, expPerfGain, 40);
        end

        function perfTiny2(testCase)
            expPerfGain = 5.8; % 1.42 original
            measurePerf(testCase, 18, expPerfGain, 40);
        end

        function perfTiny3(testCase)
            expPerfGain = 2.6; % 1.42 original
            % 2 * 3 * 5 * 7 * 11 == 2310
            measurePerf(testCase, 2310, expPerfGain, 40);
        end

        function perfSmall(testCase)
            expPerfGain = 2.1; % 3.9 original
            measurePerf(testCase, 32768, expPerfGain, 40);
        end

        function perfSmall2(testCase)
            expPerfGain = 12; % .87 original
            % 11 * 13 * 17 * 19 * 23 * 29 == 30808063
            measurePerf(testCase, 30808063, expPerfGain);
        end

        function perfBits40(testCase)
            expPerfGain = 625; % .96 original
            measurePerf(testCase, 101^6, expPerfGain, 6);
        end

        function perfPrimeBits40(testCase)
            expPerfGain = .11; % .97 original (todo: issue)
            measurePerf(testCase, nextprime(101^6), expPerfGain, 4);
        end

        function perfBits50(testCase)
            num = 2^49 - 10;
            expPerfGain = 3000; % 1.56 original
            measurePerf(testCase, num, expPerfGain, 1);
        end

        function perfPrimeBits50(testCase)
            num = nextprime(1e15);
            expPerfGain = .12;
            measurePerf(testCase, num, expPerfGain, 0);
        end

        function perfSemiprimeBits14(testCase)
            num = 101 * 103; % 10403
            expPerfGain = 3.9;
            measurePerf(testCase, num, expPerfGain);
        end

        function perfSemiprimeBits19(testCase)
            num = 641 * 643; % 412163
            expPerfGain = .93;
            measurePerf(testCase, num, expPerfGain, 2);
        end

        function perfSemiprimeBits50(testCase)
            num = 21000037 * 21001021;
            expPerfGain = .12;
            measurePerf(testCase, num, expPerfGain, 0);
        end

        function perfFlintmax(testCase)
            % 54 bits
            num = flintmax;
            tic;
            factor(num); factor(num);
            t1 = toc;
            t2 = timeit(@() factor_fast(num)) + timeit(@() factor_fast(num));
            expPerfGain = 12000; % 73000 original
            testCase.log(matlab.unittest.Verbosity.Terse, string("Act: " + t1/t2 + ", Exp: " + expPerfGain));
            testCase.verifyGreaterThan(t1/t2, expPerfGain);
        end

        function perfBits56(testCase)
            num = uint64(2)^55 - 1;
            expPerfGain = 500; % .96 original
            measurePerf(testCase, num, expPerfGain, 0);
        end
        
        function perfSequence(testCase)
            num = 60000;
            tic;
            for x = 1:num
                factor(x);
            end
            t1 = toc;
            tic
            for x = 1:num
                factor_fast(x);
            end
            t2 = toc;

            expPerfGain = 3.28;
            testCase.log(matlab.unittest.Verbosity.Terse, string("Act: " + t1/t2 + ", Exp: " + expPerfGain));
            testCase.verifyGreaterThan(t1/t2, expPerfGain);
        end
    end
end

function t2 = measurePerf(testCase, number, expPerfGain, numTrials)
    arguments
        testCase;
        number;
        expPerfGain;
        numTrials = 20;
    end

    [t1, t2] = measureIt(number, numTrials);
    testCase.log(matlab.unittest.Verbosity.Terse, string("Act: " + t1/t2 + ", Exp: " + expPerfGain));

    if t1/t2 < expPerfGain
        disp 'Retrying with twice as many trials...'
        numTrials = numTrials * 2;
        [t1, t2] = measureIt(number, numTrials);
        testCase.log(matlab.unittest.Verbosity.Terse, string("Act: " + t1/t2 + ", Exp: " + expPerfGain));
    end

    testCase.verifyGreaterThan(t1/t2, expPerfGain);

    % return average speed of factor_fast
    t2 = t2 / numTrials;
end

function [t1, t2] = measureIt(num, numTrials)
    t1 = 0;
    t2 = 0;
    if numTrials == 0
        tic;
        f1 = factor(num);
        t1 = toc;

        tic
        f2 = factor_fast(num);
        t2 = toc;
        assert(isequal(f1, f2));
        return;
    end

    for x = 1:numTrials
        t1 = t1 + timeit(@() factor(num));
        t2 = t2 + timeit(@() factor_fast(num));
    end
end
