(module recipe
  (recipe scale-recipe recipe->html)

  (import scheme (chicken base) (chicken syntax) srfi-1)

  (define-syntax λ
    (syntax-rules ()
      ((_ . rest) (lambda . rest))))

  (define-record-type quantity (make-quantity value unit locked?) quantity?
    (value quantity-value) (unit quantity-unit) (locked? quantity-locked?))

  (define-record-type ingredient (make-ingredient name quantity optional? hidden? alias reference?) ingredient?
    (name ingredient-name) (quantity ingredient-quantity)
    (optional? ingredient-optional?) (hidden? ingredient-hidden?)
    (alias ingredient-alias) (reference? ingredient-reference?))

  (define-record-type recipe (make-recipe name servings ingredients steps) recipe?
    (name recipe-name) (servings recipe-servings)
    (ingredients recipe-ingredients) (steps recipe-steps))

  (define (scale-quantity q f)
    (if (or (not q) (quantity-locked? q) (not (number? (quantity-value q))))
        q
        (make-quantity (* (quantity-value q) f) (quantity-unit q) #f)))

  (define (scale-recipe r f)
    (make-recipe (recipe-name r) (* (recipe-servings r) f)
                 (map (λ (i) (make-ingredient (ingredient-name i)
                                            (scale-quantity (ingredient-quantity i) f)
                                            (ingredient-optional? i)
                                            (ingredient-hidden? i)
                                            (ingredient-alias i)
                                            (ingredient-reference? i)))
                      (recipe-ingredients r))
                 (recipe-steps r)))

  ;; Minimal macro: just collect forms; parsing of prefixes happens in a helper
  (define-syntax ingredients
    (syntax-rules ()
      ((_ form ...)
       (list (parse-ingredient 'form) ...))))

  (define (parse-ingredient form)
    ;; form is something like (@spaghetti (g 500)) or (@?basil (g 10))
    (let* ((sym (car form))
           (name (symbol->string sym))
           (rest (cdr form))
           (optional? (string-prefix? "@?" name))
           (locked? (string-prefix? "@=" name))
           (clean-name (cond (optional? (substring name 2))
                             (locked? (substring name 2))
                             ((string-prefix? "@" name) (substring name 1))
                             (else name)))
           (qty (if (null? rest) #f (car rest))))
      (make-ingredient clean-name
                       (if (pair? qty)
                           (make-quantity (cadr qty) (symbol->string (car qty)) locked?)
                           #f)
                       optional? #f #f #f)))

  (define-syntax recipe
    (syntax-rules (servings ingredients steps)
      ((_ name (servings n) (ingredients ings) (steps stps))
       (make-recipe name n ings stps))))

  (define (recipe->html r)
    (string-append
     "<article><h1>" (recipe-name r) "</h1>"
     "<p>Servings: " (number->string (recipe-servings r)) "</p>"
     "<h2>Ingredients</h2><ul>"
     (string-concatenate
      (map (λ (i)
             (string-append "<li>"
                            (if (ingredient-optional? i) "(optional) " "")
                            (ingredient-name i) ": "
                            (if (ingredient-quantity i)
                                (string-append (number->string (quantity-value (ingredient-quantity i)))
                                               " " (quantity-unit (ingredient-quantity i)))
                                "")
                            "</li>"))
           (recipe-ingredients r)))
     "</ul><h2>Steps</h2><ol>"
     (string-concatenate (map (λ (s) (string-append "<li>" s "</li>")) (recipe-steps r)))
     "</ol></article>"))

  ) ; end module
