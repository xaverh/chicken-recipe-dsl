(* Example *)
#use "recipe.ml";;

let spaghetti = recipe "Spaghetti al pomodoro"
  ~servings:4.0
  ~ingredients:[
    ("spaghetti", G 500.0);
    ("tomato purée", Ml 250.0);
    ("salt", Pinch);
    ("basil", G 10.0)
  ]
  ~steps:[
    "Bring a large pot of water to a boil and salt it.";
    "Cook the spaghetti according to package directions.";
    "Heat the tomato purée in a pan.";
    "Drain the pasta and combine with the sauce.";
    "Season and serve with fresh basil."
  ];;

print_endline "Original:";
print_endline (recipe_to_html spaghetti);
print_endline "\n--- Scaled to 2x ---";
print_endline (recipe_to_html (scale_recipe spaghetti 2.0));;
