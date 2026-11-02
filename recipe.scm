(module recipe
  (recipe scale-recipe recipe->sxml recipe->html
   recipe? recipe-name recipe-servings recipe-ingredients recipe-steps
   make-ingredient make-cookware make-timer)

  (import scheme
          (chicken base)
          (chicken syntax)
          (chicken condition)
          (chicken port)
          srfi-1)

  (define-syntax λ
    (syntax-rules ()
      ((_ . rest) (lambda . rest))))

  ;; Quantity: number/range + unit + locked?
  (define-record-type quantity
    (make-quantity value unit locked?)
    quantity?
    (value quantity-value)
    (unit quantity-unit)
    (locked? quantity-locked?))

  ;; Ingredient with Cooklang-like flags
  (define-record-type ingredient
    (make-ingredient name quantity optional? hidden? alias reference?)
    ingredient?
    (name ingredient-name)
    (quantity ingredient-quantity)
    (optional? ingredient-optional?)
    (hidden? ingredient-hidden?)
    (alias ingredient-alias)
    (reference? ingredient-reference?))

  (define-record-type cookware
    (make-cookware name optional?)
    cookware?
    (name cookware-name)
    (optional? cookware-optional?))

  (define-record-type timer
    (make-timer name duration unit)
    timer?
    (name timer-name)
    (duration timer-duration)
    (unit timer-unit))

  (define-record-type recipe
    (make-recipe name servings metadata ingredients cookware timers steps sections)
    recipe?
    (name recipe-name)
    (servings recipe-servings)
    (metadata recipe-metadata)
    (ingredients recipe-ingredients)
    (cookware recipe-cookware)
    (timers recipe-timers)
    (steps recipe-steps)
    (sections recipe-sections))

  ;; Helpers
  (define (quantity-numeric? q)
    (and (quantity? q) (number? (quantity-value q))))

  (define (scale-quantity q factor)
    (if (or (not q) (quantity-locked? q) (not (quantity-numeric? q)))
        q
        (make-quantity (* (quantity-value q) factor)
                       (quantity-unit q)
                       #f)))

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

  ;; Macros for construction (idiomatic Scheme)
  (define-syntax ingredients
    (syntax-rules ()
      ((_ (name . rest) ...)
       (list (make-ingredient name . rest) ...))))

  (define-syntax recipe
    (syntax-rules ()
      ((_ name (servings n) (ingredients ings) (steps stps))
       (make-recipe name n '() ings '() '() stps '()))
      ((_ name (servings n) (ingredients ings) (cookware cws) (timers tms) (steps stps))
       (make-recipe name n '() ings cws tms stps '()))))

  ;; Simple HTML
  (define (quantity->sxml q)
    (if (not q) ""
        `(span ,(if (number? (quantity-value q))
                    (number->string (quantity-value q))
                    (format "~a" (quantity-value q)))
               " " (or (quantity-unit q) "")
               ,(if (quantity-locked? q) " (fixed)" ""))))

  (define (ingredient->sxml ing)
    `(li ,(if (ingredient-optional? ing) "(optional) " "")
         ,(or (ingredient-alias ing) (ingredient-name ing))
         ": " ,(quantity->sxml (ingredient-quantity ing))
         ,(if (ingredient-hidden? ing) " (hidden)" "")))

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
                        (string-concatenate (map sxml->html body))
                        "</" (symbol->string tag) ">")))
      (else "")))

  (define (recipe->html r)
    (sxml->html (recipe->sxml r)))

  ) ; end module
