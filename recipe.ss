;; Chez Scheme recipe DSL skeleton
;; λ synonym
(define-syntax λ
  (syntax-rules ()
    ((_ . rest) (lambda . rest))))

;; Records
(define-record-type recipe
  (fields name servings ingredients steps))

;; Helpers
(define (quantity-numeric? q)
  (and (pair? q) (number? (cadr q))))

(define (scale-quantity q factor)
  (cond
    ((quantity-numeric? q)
     (list (car q) (* (cadr q) factor)))
    (else q)))

(define (scale-recipe r factor)
  (make-recipe
    (recipe-name r)
    (* (recipe-servings r) factor)
    (map (λ (ing)
           (cons (car ing)
                 (scale-quantity (cdr ing) factor)))
         (recipe-ingredients r))
    (recipe-steps r)))

;; Macros
(define-syntax ingredients
  (syntax-rules ()
    ((_ (name q) ...)
     (list (cons name (quote q)) ...))))

(define-syntax steps
  (syntax-rules ()
    ((_ s ...)
     (list s ...))))

(define-syntax recipe
  (syntax-rules (servings ingredients steps)
    ((_ name (servings n) (ingredients ings) (steps stps))
     (make-recipe name n ings stps))
    ((_ name (ingredients ings) (steps stps))
     (make-recipe name 1 ings stps))))

;; SXML / HTML
(define (quantity->sxml q)
  (cond
    ((quantity-numeric? q)
     `(span ,(number->string (cadr q)) " " ,(symbol->string (car q))))
    ((symbol? q)
     `(span ,(symbol->string q)))
    (else
     `(span ,(format "~a" q)))))

(define (ingredient->sxml ing)
  `(li ,(car ing) ": " ,(quantity->sxml (cdr ing))))

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
     (let ((tag (car s))
           (body (cdr s)))
       (string-append
        "<" (symbol->string tag) ">"
        (apply string-append (map sxml->html body))
        "</" (symbol->string tag) ">")))
    (else "")))

(define (recipe->html r)
  (sxml->html (recipe->sxml r)))
