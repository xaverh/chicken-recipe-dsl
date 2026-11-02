# Recipe DSL — OCaml branch

Attempt at a more DSL-like surface using a small combinator / quotation style
(OCaml has no built-in hygienic macros comparable to Scheme; PPX would be needed for a true macro).

## Surface

```ocaml
let r = recipe "Spaghetti al pomodoro"
  [ servings 4;
    ingredients [
      ("spaghetti", g 500);
      ("tomato purée", ml 250);
      ("salt", pinch)
    ];
    steps [
      "Boil the pasta.";
      "Heat the sauce."
    ]
  ]
```
