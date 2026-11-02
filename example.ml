open Recipe

let spaghetti = [%recipe {|
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

let () =
  print_endline "Original:";
  print_endline (recipe_to_html spaghetti);
  print_endline "\n--- Scaled to 2x ---";
  print_endline (recipe_to_html (scale_recipe spaghetti 2.0))
