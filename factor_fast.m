function f = factor_fast(N)
%FACTOR Prime factors.
%   FACTOR(N) returns a vector containing the prime factors of N.
%   Copyright 1984-2014 The MathWorks, Inc. 

    if ~isscalar(N)
        error(message('MATLAB:factor:NonScalarInput'));
    elseif ~isreal(N) || N < 0 || floor(N) ~= N
        error(message('MATLAB:factor:InputNotPosInt')); 
    elseif isfloat(N) && N > flintmax(class(N))
        error(message('MATLAB:factor:InputOutOfRange'));
    end

    f = trialDivision(N);
    %f = wheelFactorization(N);
    %f = original(N);
end

% https://en.wikipedia.org/wiki/Trial_division
function f = trialDivision(N)
    if N < 4
        f = floor(N); 
        return;
    end

    issp = issparse(N);
    if issp
        N = full(N);
    end

    if isa(N, 'double')
        f = [];
    else
        f = cast([], class(N));
    end

    % accumulate powers of 2...
    while mod(N, 2) == 0
        N = N / 2;
        f = [f, 2];
    end

    % ...and 3
    while mod(N, 3) == 0
        N = N / 3;
        f = [f, 3];
    end

    oddNum = 5;
    accumulator = 9;
    temp = 16;
    while 1
        accumulator = accumulator + temp;
        if accumulator > N
            break; 
        elseif mod(N, oddNum) == 0
            f = [f, oddNum]; %#ok<AGROW>
            N = N / oddNum;
            accumulator = accumulator - temp;
        else 
            oddNum = oddNum + 2;
            temp = temp + 8;
        end
    end

    if N ~= 1
        f = [f, N];
    end

    if issp
        f = sparse(f);
    end
end

% https://en.wikipedia.org/wiki/Wheel_factorization
function f = wheelFactorization(N)
    if N < 4
        f = floor(N); 
        return;
    end

    issp = issparse(N);
    if issp
        N = full(N);
    end

    if isa(N, 'double')
        f = [];
    else
        f = cast([], class(N));
    end

    for smallPrime = [2, 3, 5]
        while mod(N, smallPrime) == 0
            N = N / smallPrime;
            f = [f, smallPrime]; %#ok<AGROW>
        end
    end

    k = 7;
    idx = 1;
    seq = [4, 2, 4, 2, 4, 6, 2, 6];
    while k * k <= N
        if mod(N, k) == 0
            f = [f, k]; %#ok<AGROW>
            N = N / k;
        else
            k = k + seq(idx);
            if idx < 8
                idx = idx + 1;
            else
                idx = 1;
            end
        end
    end

    if N ~= 1
        f = [f, N];
    end

    if issp
        f = sparse(f);
    end
end

function f = original(N)
    if N < 4
        f = floor(N); 
        return;
    else
        [f, N] = removeSmallPrimes(N);
    end

    if (isa(N,'uint64') || isa(N,'int64')) && N > flintmax
        upperBound = 2.^(nextpow2(N)/2);
    else
        upperBound = cast(sqrt(double(N)), class(N));
    end

    p = primes(upperBound);

    while N > 1
        d = find(rem(N, p)==0);
        if isempty(d)
            f = [f, N];
            break;
        end
        p = p(d);
        f = [f, p];
        N = N/prod(p);
    end

    f = sort(f);
    if issparse(N)
        f = sparse(f);
    end
end

function [factors, N] = removeSmallPrimes(N)
    factors = [];
    [f, N] = removeSmallPrime(2, N);
    factors = [factors, f];
    [f, N] = removeSmallPrime(3, N);
    factors = [factors, f];
    %[f, N] = removeSmallPrime(5, N);
    %factors = [factors, f];

    factors = cast(factors, class(N));
end

function [f, N] = removeSmallPrime(prime, N)
    numFactors = 0;
    while mod(N, prime) == 0
        numFactors = numFactors + 1;
        N = N / prime;
    end

    f = repmat(prime, [1, numFactors]);
end

%{
% 4-29-21 original: removing pow2&3
function f = factor_fast(N)
%FACTOR Prime factors.
%   FACTOR(N) returns a vector containing the prime factors of N.
%   Copyright 1984-2014 The MathWorks, Inc. 

    if ~isscalar(N)
        error(message('MATLAB:factor:NonScalarInput'));
    elseif ~isreal(N) || N < 0 || floor(N) ~= N
        error(message('MATLAB:factor:InputNotPosInt')); 
    elseif isfloat(N) && N > flintmax(class(N))
        error(message('MATLAB:factor:InputOutOfRange'));
    end

    if N < 4
        f = floor(N); 
        return;
    else
        [f, N] = removeSmallPrimes(N);
    end

    if (isa(N,'uint64') || isa(N,'int64')) && N > flintmax
        upperBound = 2.^(nextpow2(N)/2);
    else
        upperBound = cast(sqrt(double(N)), class(N));
    end

    p = primes(upperBound);

    while N > 1
        d = find(rem(N, p)==0);
        if isempty(d)
            f = [f, N];
            break;
        end
        p = p(d);
        f = [f, p];
        N = N/prod(p);
    end

    f = sort(f);
    if issparse(N)
        f = sparse(f);
    end
end

function [factors, N] = removeSmallPrimes(N)
    factors = [];
    [f, N] = removeSmallPrime(2, N);
    factors = [factors, f];
    [f, N] = removeSmallPrime(3, N);
    factors = [factors, f];
    %[f, N] = removeSmallPrime(5, N);
    %factors = [factors, f];

    factors = cast(factors, class(N));
end

function [f, N] = removeSmallPrime(prime, N)
    numFactors = 0;
    while mod(N, prime) == 0
        numFactors = numFactors + 1;
        N = N / prime;
    end

    f = repmat(prime, [1, numFactors]);
end
%}
