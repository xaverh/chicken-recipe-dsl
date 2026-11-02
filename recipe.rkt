#lang racket/base
(require racket/string)

(provide recipe scale-recipe recipe->html)

(struct quantity (value unit locked?) #:transparent)
(struct ingredient (name quantity optional? hidden? alias reference?) #:transparent)
(struct recipe (name servings ingredients steps) #:transparent)

(define (scale-quantity q f)
  (if (or (not q) (quantity-locked? q) (not (number? (quantity-value q))))
      q
      (quantity (* (quantity-value q) f) (quantity-unit q) #f)))

(define (scale-recipe r f)
  (recipe (recipe-name r) (* (recipe-servings r) f)
          (map (λ (i) (ingredient (ingredient-name i)
                                 (scale-quantity (ingredient-quantity i) f)
                                 (ingredient-optional? i)
                                 (ingredient-hidden? i)
                                 (ingredient-alias i)
                                 (ingredient-reference? i)))
               (recipe-ingredients r))
          (recipe-steps r)))

(define (parse-ingredient form)
  (let* ([sym (car form)]
         [name (symbol->string sym)]
         [rest (cdr form)]
         [optional? (string-prefix? name "@?")]
         [locked? (string-prefix? name "@=")]
         [clean (cond [optional? (substring name 2)]
                      [locked? (substring name 2)]
                      [(string-prefix? name "@") (substring name 1)]
                      [else name])]
         [qty (if (null? rest) #f (car rest))])
    (ingredient clean
                (if (pair? qty)
                    (quantity (cadr qty) (symbol->string (car qty)) locked?)
                    #f)
                optional? #f #f #f)))

(define-syntax-rule (ingredients form ...)
  (list (parse-ingredient 'form) ...))

(define-syntax-rule (recipe name (servings n) (ingredients ings) (steps stps))
  (recipe name n ings stps))

(define (recipe->html r)
  (string-append
   "<article><h1>" (recipe-name r) "</h1>"
   "<p>Servings: " (number->string (recipe-servings r)) "</p>"
   "<h2>Ingredients</h2><ul>"
   (string-join
    (map (λ (i)
           (string-append "<li>"
                          (if (ingredient-optional? i) "(optional) " "")
                          (ingredient-name i) ": "
                          (if (ingredient-quantity i)
                              (string-append (number->string (quantity-value (ingredient-quantity i)))
                                             " " (quantity-unit (ingredient-quantity i)))
                              "")
                          "</li>"))
         (recipe-ingredients r))
    "")
   "</ul><h2>Steps</h2><ol>"
   (string-join (map (λ (s) (string-append "<li>" s "</li>")) (recipe-steps r)) "")
   "</ol></article>"))
