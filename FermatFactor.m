% https://en.wikipedia.org/wiki/Fermat%27s_factorization_method
% try to find a^2 - N = b^2
function f = FermatFactor(N)
    f = [];
    f = FermatFactorRecursive(N, f);
end

function f = FermatFactorRecursive(N, f)
    if N < 4
        f = floor(N); 
        return;
    end

    % accumulate powers of 2
    while mod(N, 2) == 0
        N = N / 2;
        f = [f, 2];
    end

    if isprime_fast(N)
        f = [f, N];
        return;
    end

    % try to find a^2 - N = b^2
    a = uint64(ceil(sqrt(N)));
    b2 = a*a - N;
    sqrtB2 = sqrt(double(b2));
    
    while ~isSquare(sqrtB2, b2)
        a = a + 1;
        b2 = a*a - N;
        sqrtB2 = sqrt(double(b2));
    end

    a = double(a);
    f1 = a - sqrtB2;
    f2 = a + sqrtB2;
    if ~isprime_fast(f1)
        f1 = FermatFactor(f1);
    end
    if ~isprime_fast(f2)
        f2 = FermatFactor(f2);
    end
	f = [f, f1, f2];
    f(f == 1) = [];
    f = sort(f);
end

function bool = isSquare(sqrtB2, b2)
    % return whether b is square?
    bool = floor(sqrtB2) == sqrtB2 && sqrtB2 ^ 2 == b2;
end
