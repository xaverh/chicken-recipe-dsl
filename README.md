# Chicken Recipe DSL

Minimal working skeleton of a Chicken Scheme DSL for recipes.

## Features
- Nice surface syntax via macros
- Structured data (records)
- Recipe scaling
- SXML generation for HTML publishing

## Usage

```scheme
(import recipe)

(define r
  (recipe "Spaghetti al pomodoro"
    (servings 4)
    (ingredients
      ("spaghetti" (g 500))
      ("tomato purée" (ml 250))
      ("salt" pinch))
    (steps
      "Boil the pasta."
      "Heat the sauce."
      "Combine and season.")))

(recipe->html (scale-recipe r 2))
```

## Dependencies
- CHICKEN Scheme 5+
- Optional: `sxml-transforms` or `chiccup` for richer HTML (the skeleton includes a simple SXML emitter)

## Files
- `recipe.scm` — the module
- `example.scm` — runnable example
