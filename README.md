# Recipe DSL — Chez Scheme branch

Minimal Chez Scheme port of the recipe DSL.

Chez has excellent R6RS support and native Unicode. λ is defined as a synonym.

## Usage

```scheme
(load "recipe.ss")

(define r
  (recipe "Spaghetti al pomodoro"
    (servings 4)
    (ingredients
      ("spaghetti" (g 500))
      ("tomato purée" (ml 250))
      ("salt" pinch))
    (steps
      "Boil the pasta."
      "Heat the sauce.")))

(recipe->html (scale-recipe r 2))
```

Run with Chez Scheme (`scheme` or `petite`).
