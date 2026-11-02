#lang racket/base
(require "recipe.rkt")

(define spaghetti
  (recipe "Spaghetti al pomodoro"
    (servings 4)
    (ingredients
      ("spaghetti" (quantity 500 "g" #f) #f #f #f #f)
      ("tomato purée" (quantity 250 "ml" #f) #f #f #f #f)
      ("salt" (quantity 1 "pinch" #t) #f #f #f #f)
      ("basil" (quantity 10 "g" #f) #t #f #f #f))
    (steps
      "Bring a large pot of water to a boil and salt it."
      "Cook the spaghetti according to package directions."
      "Heat the tomato purée in a pan."
      "Drain the pasta and combine with the sauce."
      "Season and serve with fresh basil.")))
