% https://www.geeksforgeeks.org/pollard-p-1-algorithm/
function f = PollardPMinus1(N)
    % defining base
    a = 2;
   
    % defining exponent
    e = 2;
   
    % iterate till a prime factor is obtained
    while true
        % recomputing a as required
        a = ModExp(a, e, N);
   
        % finding gcd of a-1 and n
        % using math function
        f = gcdSimple(a-1, N);
   
        % check if factor obtained
        if f > 1
            % return the factor
            break;
        end
        % else increase exponent by one for next round
        e = e + 1;
    end
end

function a = gcdSimple(a, b)
    while b ~= 0
        remainder = mod(a, b);
        a = b;
        b = remainder;
    end
end

function smooth = Powersmooth(N)
    lgE = log(N);
    smooth = 1;
    for x = primes(N)
        smooth = smooth * x ^ floor(lgE / log(x));
    end
end
