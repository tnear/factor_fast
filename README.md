# factor_fast

## Syntax
The syntax for *factor_fast* is identical to *factor*. It accepts a numeric scalar then returns a sorted list of irreducible factors. The only difference lies in the techniques used to determine the factors. *factor_fast* uses carefully incrementing trial division.
```
>> factor_fast(5040)

ans =

     2     2     2     2     3     3     5     7
```

## Performance comparison between *factor* and *factor_fast*
This repository offers multiple factoring functions. factor_fast is tailored to factor small numbers quickly. For 2- to 32-bit numbers, factor_fast often runs 2x to 20x faster than MATLAB's bulit-in *factor*:

```
% 32-bit composite
>> timeit(@() factor(3080806313)) / timeit(@() factor_fast(3080806313))

ans =

   19.3342

% 12-bit pseudoprime
>> timeit(@() factor(3127)) / timeit(@() factor_fast(3127))

ans =

    7.0030
```
