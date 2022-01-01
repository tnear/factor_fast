classdef TonelliShanksTest < matlab.unittest.TestCase
    methods (Test)
        function basic(testCase)
            testCase.assertTrue(TonelliShanks(5, 41) == 28);
            testCase.assertTrue(TonelliShanks(11, 19) == 7);
            testCase.assertTrue(TonelliShanks(10, 563) == 130);
            TonelliShanks(uint32(3610853120), uint32(1092133619));
            testCase.assertTrue(TonelliShanks(uint64(18446744073709551615), uint64(18446744073689551507)) == ...
                uint64(5305779583712067695));
        end

        function bigUint64(testCase)
            testCase.assertTrue(TonelliShanks(uint64(18050093798709551615), uint64(18413156167709551609)) == ...
                uint64(8946497098267709779));
            testCase.assertTrue(TonelliShanks(uint64(18446744070055913549), uint64(18446744071310531089)) == ...
                uint64(13553528427235932825));
            testCase.assertTrue(TonelliShanks(uint64(17567508691026930175), uint64(18184940199599514961)) == ...
                uint64(18042490339097315912));
            testCase.assertTrue(TonelliShanks(uint64(8581605089597216767), uint64(17324770135538676721)) == ...
                uint64(12998998442469749257));
            testCase.assertTrue(TonelliShanks(uint64(17417951507785800705), uint64(17831102154604390129)) == ...
                uint64(16661079972702396985));
            testCase.assertTrue(TonelliShanks(uint64(18246577669417175128), uint64(18434728819080138049)) == ...
                uint64(6595895005746540832));
        end

        function randoms(testCase)
            for x = 1:100
                a = intmax('uint64') - randi(intmax('int32'))^2 + randi(intmax('uint32'));
                b = intmax('uint64') - randi(intmax('int32'))^2 + randi(intmax('uint32'));
                b = prevprime(b);
                disp(a);
                disp(b);
                tic;
                r = TonelliShanks(a, b);
                t1 = toc;
                if t1 > .8
                    keyboard;
                end
            end
        end
    end
end
