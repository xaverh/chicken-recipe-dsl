# Recipe DSL — Emacs Lisp branch

Minimal Emacs Lisp port of the recipe DSL.

Uses cl-defstruct (from cl-lib), defmacro, and a λ synonym.

## Usage

In Emacs:

```elisp
(load "recipe.el")

(setq r
  (recipe "Spaghetti al pomodoro"
    :servings 4
    :ingredients '(("spaghetti" (g 500))
                   ("tomato purée" (ml 250))
                   ("salt" pinch))
    :steps '("Boil the pasta."
             "Heat the sauce.")))

(recipe->html (scale-recipe r 2))
```

Or evaluate in a buffer.
