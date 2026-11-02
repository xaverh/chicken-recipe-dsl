;; Example for Chez
(load "recipe.ss")

(define spaghetti
  (recipe "Spaghetti al pomodoro"
    (servings 4)
    (ingredients
      ("spaghetti" (g 500))
      ("tomato purée" (ml 250))
      ("salt" pinch)
      ("basil" (g 10)))
    (steps
      "Bring a large pot of water to a boil and salt it."
      "Cook the spaghetti according to package directions."
      "Heat the tomato purée in a pan."
      "Drain the pasta and combine with the sauce."
      "Season and serve with fresh basil.")))

(display "Original:\n")
(display (recipe->html spaghetti))
(newline)
(display "\n--- Scaled to 2x ---\n")
(display (recipe->html (scale-recipe spaghetti 2)))
(newline)
