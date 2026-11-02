# Chicken Recipe DSL — Racket branch

This branch contains a Racket port of the recipe DSL, demonstrating the advantages of Racket’s language-oriented features over the Chicken version on `main`.

## Why Racket is better here

See the comparison notes below and the code in `recipe.rkt`.

## Files
- `recipe.rkt` — the DSL (syntax-parse macros, contracts-friendly, good error messages)
- `example.rkt` — runnable example
- `racket-vs-chicken.md` — short comparison

## Quick start

```bash
racket example.rkt
```

Or in DrRacket: open `example.rkt` and Run.
