;; Chez Scheme recipe DSL with Cooklang MVP features
(define-syntax λ
  (syntax-rules ()
    ((_ . rest) (lambda . rest))))

(define-record-type quantity
  (fields value unit locked?))

(define-record-type ingredient
  (fields name quantity optional? hidden? alias reference?))

(define-record-type cookware
  (fields name optional?))

(define-record-type timer
  (fields name duration unit))

(define-record-type recipe
  (fields name servings metadata ingredients cookware timers steps sections))

(define (scale-quantity q factor)
  (if (or (not q) (quantity-locked? q) (not (number? (quantity-value q))))
      q
      (make-quantity (* (quantity-value q) factor) (quantity-unit q) #f)))

(define (scale-recipe r factor)
  (make-recipe
    (recipe-name r)
    (* (recipe-servings r) factor)
    (recipe-metadata r)
    (map (λ (ing)
           (make-ingredient (ingredient-name ing)
                            (scale-quantity (ingredient-quantity ing) factor)
                            (ingredient-optional? ing)
                            (ingredient-hidden? ing)
                            (ingredient-alias ing)
                            (ingredient-reference? ing)))
         (recipe-ingredients r))
    (recipe-cookware r)
    (recipe-timers r)
    (recipe-steps r)
    (recipe-sections r)))

(define-syntax ingredients
  (syntax-rules ()
    ((_ (name qty opt? hid? ali? ref?) ...)
     (list (make-ingredient name qty opt? hid? ali? ref?) ...))))

(define-syntax recipe
  (syntax-rules (servings ingredients steps)
    ((_ name (servings n) (ingredients ings) (steps stps))
     (make-recipe name n '() ings '() '() stps '()))))

(define (quantity->sxml q)
  (if (not q) ""
      `(span ,(if (number? (quantity-value q))
                  (number->string (quantity-value q))
                  (format "~a" (quantity-value q)))
             " " ,(or (quantity-unit q) ""))))

(define (ingredient->sxml ing)
  `(li ,(if (ingredient-optional? ing) "(optional) " "")
       ,(or (ingredient-alias ing) (ingredient-name ing))
       ": " ,(quantity->sxml (ingredient-quantity ing))))

(define (recipe->sxml r)
  `(article
     (h1 ,(recipe-name r))
     (p "Servings: " ,(number->string (recipe-servings r)))
     (h2 "Ingredients")
     (ul ,@(map ingredient->sxml (recipe-ingredients r)))
     (h2 "Steps")
     (ol ,@(map (λ (s) `(li ,s)) (recipe-steps r)))))

(define (sxml->html s)
  (cond
    ((string? s) s)
    ((number? s) (number->string s))
    ((symbol? s) (symbol->string s))
    ((pair? s)
     (let ((tag (car s)) (body (cdr s)))
       (string-append "<" (symbol->string tag) ">"
                      (apply string-append (map sxml->html body))
                      "</" (symbol->string tag) ">")))
    (else "")))

(define (recipe->html r)
  (sxml->html (recipe->sxml r)))
