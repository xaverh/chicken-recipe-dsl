# Recipe DSL — OCaml branch

Minimal OCaml port. Algebraic data types + functions for scaling and HTML.

## Usage

```ocaml
#use "recipe.ml";;

let r = recipe "Spaghetti al pomodoro"
  ~servings:4
  ~ingredients:[
    ("spaghetti", G 500);
    ("tomato purée", Ml 250);
    ("salt", Pinch)
  ]
  ~steps:[
    "Boil the pasta.";
    "Heat the sauce."
  ];;

print_endline (recipe_to_html (scale_recipe r 2.0));;
```
