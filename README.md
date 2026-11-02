# Recipe DSL — OCaml branch (natural PPX syntax)

The PPX now accepts a string that looks like a normal recipe:

```ocaml
let r = [%recipe {|
Spaghetti al pomodoro
Servings: 4

Ingredients:
- 500 g spaghetti
- 250 ml tomato purée
- pinch salt
- 10 g basil

Steps:
1. Bring a large pot of water to a boil and salt it.
2. Cook the spaghetti according to package directions.
3. Heat the tomato purée in a pan.
4. Drain the pasta and combine with the sauce.
5. Season and serve with fresh basil.
|}]
```

## Build & run

```bash
dune build
dune exec ./example.exe
```
