% Solve the congruence r^2 === n (mod p)
% https://eli.thegreenplace.net/2009/03/07/computing-modular-square-roots-in-python
% https://en.wikipedia.org/wiki/Tonelli%E2%80%93Shanks_algorithm
function r = TonelliShanks(a, p)
    arguments
        a uint64;
        p uint64;
    end
    %assert(isprime_fast(p));

    r = 0;
    if a == 0 || p == 2 || legendreSymbol(a, p) ~= 1
        return;
    elseif mod(p, 4) == 3
        r = ModExp(a, (p + 1) / 4, p);
        assert(ModExp(r, 2, p) == mod(a, p));
        return;
    end

    % accumulate powers of 2
    s = p - 1;
    numPow2 = 0;
    while mod(s, 2) == 0
        s = s / 2;
        numPow2 = numPow2 + 1;
    end

    % find n with Legendre symbol -1 (half of all numbers have this property)
    n = uint64(2);
    while legendreSymbol(n, p) ~= -1
        n = n + 1;
    end
    
    x = ModExp(a, (s + 1) / 2, p);
    b = ModExp(a, s, p);
    g = ModExp(n, s, p);
    r = numPow2;

    while 1
        t = b;
        m = 0;
        for idx = 0 : r-1
            m = idx;
            if t == 1
                break;
            end
            t = ModExp(t, 2, p);
        end

        if m == 0
            r = x;
            break;
        end

        assert(r > m);
        assert(r - m - 1 < 1024);
        gs = ModExp(g, 2 ^ (r - m - 1), p);
        g = ModMultiply(gs, gs, p);
        x = ModMultiply(x, gs, p);
        b = ModMultiply(b, g, p);
        r = m;
    end

    if r > 0
        assert(ModExp(r, 2, p) == mod(a, p));
    end
end

% calculate Legendre symbol using Euler's criterion
function symb = legendreSymbol(a, p)
    symb = ModExp(a, (p - 1) / 2, p);
    if symb == p - 1
        symb = -1;
    end
end
