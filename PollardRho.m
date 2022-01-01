% Pollard's rho algorithm
% https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm
function f = PollardRho(N)
    if N < 4
        f = floor(N); 
        return;
    end
    f = [];
    while mod(N, 2) == 0
        N = N / 2;
        f = [f, 2];
    end

    while N ~= 1
        foundFactor = findFactor(N);
        if foundFactor == 0
            f = [f, factor(N)];
            break;
        else
            f = [f, factor(foundFactor)];
            N = N / foundFactor;
        end
    end

    f = sort(f);
end

function result = g(input, N)
    arguments
        input uint64;
        N uint64;
    end
    result = ModMultiply(input, input, N);
    result = ModAdd(result, 1, N);
    result = double(result);
end

function f = findFactor(N)
    x = 2;
    y = 2;
    d = 1;
    %c = randi(N - 1);
    while d == 1
        x = g(x, N);
        y = g(y, N);
        y = g(y, N);
        d = gcdSimple(max(x, y) - min(x, y), N);
    end

    if d == N
        f = 0; % not found
    else
        f = d;
    end
end

function a = gcdSimple(a, b)
    while b ~= 0
        remainder = mod(a, b);
        a = b;
        b = remainder;
    end
end
