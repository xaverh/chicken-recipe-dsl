;; Chez: Cooklang-style prefixes, minimal macros
(define-syntax λ
  (syntax-rules ()
    ((_ . rest) (lambda . rest))))

(define-record-type quantity (fields value unit locked?))
(define-record-type ingredient (fields name quantity optional? hidden? alias reference?))
(define-record-type recipe (fields name servings ingredients steps))

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

(define (parse-ingredient form)
  (let* ((sym (car form))
         (name (symbol->string sym))
         (rest (cdr form))
         (optional? (and (>= (string-length name) 2) (string=? (substring name 0 2) "@?")))
         (locked? (and (>= (string-length name) 2) (string=? (substring name 0 2) "@=")))
         (clean (cond (optional? (substring name 2))
                      (locked? (substring name 2))
                      ((and (>= (string-length name) 1) (string=? (substring name 0 1) "@"))
                       (substring name 1))
                      (else name)))
         (qty (if (null? rest) #f (car rest))))
    (make-ingredient clean
                     (if (pair? qty)
                         (make-quantity (cadr qty) (symbol->string (car qty)) locked?)
                         #f)
                     optional? #f #f #f)))

(define-syntax ingredients
  (syntax-rules ()
    ((_ form ...)
     (list (parse-ingredient 'form) ...))))

(define-syntax recipe
  (syntax-rules (servings ingredients steps)
    ((_ name (servings n) (ingredients ings) (steps stps))
     (make-recipe name n ings stps))))

(define (recipe->html r)
  (string-append
   "<article><h1>" (recipe-name r) "</h1>"
   "<p>Servings: " (number->string (recipe-servings r)) "</p>"
   "<h2>Ingredients</h2><ul>"
   (apply string-append
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
   (apply string-append (map (λ (s) (string-append "<li>" s "</li>")) (recipe-steps r)))
   "</ol></article>"))
