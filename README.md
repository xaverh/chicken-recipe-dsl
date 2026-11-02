# Recipe DSL — OCaml branch (natural PPX syntax)

The PPX accepts a string that looks like a normal recipe. Ingredients use the real bullet character (•) and steps are plain lines:

```ocaml
let r = [%recipe {|
Spaghetti al pomodoro
Servings: 4

Ingredients:
• 500 g spaghetti
• 250 ml tomato purée
• pinch salt
• 10 g basil

Steps:
Bring a large pot of water to a boil and salt it.
Cook the spaghetti according to package directions.
Heat the tomato purée in a pan.
Drain the pasta and combine with the sauce.
Season and serve with fresh basil.
|}]
```

## Build & run

```bash
dune build
dune exec ./example.exe
```
