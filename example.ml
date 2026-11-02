open Recipe

(* Pure recipe definition *)
let spaghetti = [%recipe {|
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

(* Demo / driver code (not part of the recipe) *)
let demo () =
  print_endline "Original:";
  print_endline (recipe_to_html spaghetti);
  print_endline "\n--- Scaled to 2x ---";
  print_endline (recipe_to_html (scale_recipe spaghetti 2.0))

let () = demo ()
