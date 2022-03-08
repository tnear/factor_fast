# factor_fast
*factor_fast* is a work-in-progress (and partial) replacement for MATLAB's documented [*factor*](https://www.mathworks.com/help/matlab/ref/factor.html) function. It is not yet as polished or tested as [*isprime_fast*](https://github.com/tnear/isprime_fast).

## Syntax
The syntax for *factor_fast* is identical to *factor*. It accepts a numeric scalar then returns a sorted list of irreducible factors. The only difference lies in the techniques used to determine the factors. *factor_fast* uses carefully incrementing trial division.
```
>> factor_fast(5040)

ans =

     2     2     2     2     3     3     5     7
```

## Performance comparison between *factor* and *factor_fast*
This repository offers multiple factoring functions. *factor_fast* is tailored to factor small numbers quickly. For 2- to 32-bit numbers, factor_fast often runs 2x to 20x faster than MATLAB's bulit-in *factor*:

```
% 32-bit composite
>> timeit(@() factor(3080806313)) / timeit(@() factor_fast(3080806313))
speedupFactor =

   19.3342

% 12-bit pseudoprime
>> timeit(@() factor(3127)) / timeit(@() factor_fast(3127))
speedupFactor =

    7.0030
```

## Factoring larger primes
### Shanks's square forms factorization
[Shanks's square forms factorization](https://en.wikipedia.org/wiki/Shanks%27s_square_forms_factorization) (SQUFOF) is an enhancement on the simpler Fermat's factorization method (see [FermatFactor.m](https://github.com/tnear/factor_fast/blob/master/FermatFactor.m)):

MATLAB's *factor* funtion first calculates all primes up to *sqrt(N)*. Creating this prime sieve takes ~30 seconds for 64-bit numbers. SQUFOF bypasses this by looking for congruences and perfect squares which greatly accelerates performance:
```
>> num = int64(9223372036854775781);
>> assert(isequal(SquareFormsFactorization(num), factor(num)));
>> tic, SquareFormsFactorization(num); seconds(toc)

duration = 

   0.13129 sec

>> tic, factor(num); seconds(toc)

duration = 

   34.54 sec
```

However, the reason that *SquareFormsFactorization* hasn't yet been rolled into *factor_fast* is due to its inherent 64-bit overflow limits from its multiply checks.

### Other factor algorithms included in this repository
- Fermat's factorization method ([FermatFactor.m](FermatFactor.m))
- Pollard's rho algorithm ([PollardRho.m](PollardRho.m))
- Pollard's p − 1 algorithm ([PollardPMinus1.m](PollardPMinus1.m))
- Tonelli–Shanks algorithm ([TonelliShanks.m](TonelliShanks.m))
