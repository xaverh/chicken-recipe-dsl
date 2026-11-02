;; Example usage
;; Run with: csi -s example.scm

(import recipe)

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

(print "Original:")
(print (recipe->html spaghetti))
(print "\n--- Scaled to 2x ---")
(print (recipe->html (scale-recipe spaghetti 2)))
