# Recipe DSL — OCaml branch (with PPX)

Uses a custom PPX rewriter so you can write recipes with an extension point:

```ocaml
let r = [%recipe
  "Spaghetti al pomodoro"
  (servings 4)
  (ingredients
    ("spaghetti" (g 500))
    ("tomato purée" (ml 250))
    ("salt" pinch))
  (steps
    "Boil the pasta."
    "Heat the sauce.")
]
```

## Build & run

```bash
dune build
dune exec ./example.exe
```

Requires OCaml + Dune. The PPX lives in `ppx/`.
