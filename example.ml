open Recipe

(* PPX still uses the natural string; prefixes are parsed inside *)
let spaghetti = [%recipe {|
Spaghetti al pomodoro
Servings: 4

Ingredients:
• 500 g spaghetti
• 250 ml tomato purée
• =1 pinch salt
• ?10 g basil

Steps:
Bring a large pot of water to a boil and salt it.
Cook the spaghetti according to package directions.
Heat the tomato purée in a pan.
Drain the pasta and combine with the sauce.
Season and serve with fresh basil.
|}]
