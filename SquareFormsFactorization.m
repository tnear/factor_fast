% https://en.wikipedia.org/wiki/Shanks%27s_square_forms_factorization
function f = SquareFormsFactorization(N)
    f = [];
    if ~isa(N, 'double')
        f = cast(f, class(N));
    end

    f = SquareFormsFactorizationRecursive(N, f);
end

function f = SquareFormsFactorizationRecursive(N, f)
    if N < 4
        f = floor(N); 
        return;
    end

    % remove powers 2 and ensure that N is odd
    while mod(N, 2) == 0
        N = N / 2;
        f = [f, 2]; %#ok<AGROW>
    end

    if N == 1
        return;
    elseif isprime_fast(N)
        % N is already a prime factor
        f = [f, N];
        return;
    end

    squareRootN = uint64(floor(sqrt(double(N)) + .5)); 
    if isSquare(double(squareRootN), N)
        % Shanks cannot factor perfect squares
        sqFactors = factor_fast(squareRootN);
        f = [f, sqFactors, sqFactors];
        f(f == 1) = [];
        f = cast(sort(f), class(N));
        return;
    end

    r = 0;
    % 13 needed for 988193 and 3636679; 5*13 for 4558849; 3*13 for 5214317
    multiplier = [1, 3, 5, 7, 11, 13, 3*5, 3*7, 3*11, 5*7, 5*11, 7*11, 3*5*7, ...
        3*5*11, 3*7*11, 5*7*11, 3*5*7*11, 3*13, 5*13];

    origClass = class(N);
    N = cast(N, 'uint64');
    B = 3 * uint64(2 * floor(sqrt(double(2*squareRootN))));
    for k = 1 : numel(multiplier)
        D = multiplier(k) * N;
        if D == uint64(18446744073709551615)
            % uint64 overflow, cannot factor
            break;
        end
        Po = uint64(floor(sqrt(double(D))));
        Pprev = Po;
        P = Po;
        Qprev = 1;
        Q = D - Po*Po;
        
        idx = 2;
        while idx < B
            [P, Qprev, Q] = updateState(Po, P, Pprev, Q, Qprev);
            r = uint64(floor(sqrt(double(Q))));
            if mod(idx, 2) == 0 && r*r == Q
                break;
            end
            Pprev = P;
            idx = idx + 1;
        end
        if idx >= B
            % is > needed?
            continue;
        end
        tmpDiff = Po - P;
        b = (tmpDiff - rem(tmpDiff, r)) / r; % idivide(Po - P, r);
        Pprev = b*r + P;
        P = Pprev;
        Qprev = r;
        Q = (D - Pprev*Pprev)/Qprev;
        while true
            Pprev = P;
            [P, Qprev, Q] = updateState(Po, P, Pprev, Q, Qprev);
            if P == Pprev
                break;
            end
        end

        f1 = gcdSimple(N, Qprev);
        if f1 ~= 1 && f1 ~= N
            % found non-trivial factor
            f2 = N / f1;

            % check if factors 1 & 2 need addtional factoring
            if ~isprime_fast(f1)
                f1 = SquareFormsFactorization(f1);
            end
            if ~isprime_fast(f2)
                f2 = SquareFormsFactorization(f2);
            end

            if isempty(f1) || isempty(f2)
                % could not factor subproblem, return empty
                f = [];
            else
                f = sort([f, f1, f2]);
            end
            f = cast(f, origClass);
            return;
        end
    end

    f = [];
end

function a = gcdSimple(a, b)
    while b ~= 0
        remainder = mod(a, b);
        a = b;
        b = remainder;
    end
end

function bool = isSquare(nSqrt, sqr)
    % is num square?
    bool = floor(nSqrt) == nSqrt && nSqrt ^ 2 == sqr;
end

function [P, q, Q] = updateState(Po, P, Pprev, Q, Qprev)
    tmpSum = Po + P;
    divResult = (tmpSum - rem(tmpSum, Q)) / Q; % idivide(Po + P, Q)
    P = divResult*Q - P;
    q = Q;
    Q = Qprev;
    if Pprev < P
        % avoid negatives with uint
        Q = Q - divResult*(P - Pprev);
    else
        Q = Q + divResult*(Pprev - P);
    end
end
