#lang racket/base

(require (for-syntax racket/base syntax/parse)
         racket/contract racket/string)

(provide (contract-out
          [recipe? predicate/c]
          [scale-recipe (-> recipe? real? recipe?)]
          [recipe->html (-> recipe? string?)])
         recipe)

(struct quantity (value unit locked?) #:transparent)
(struct ingredient (name quantity optional? hidden? alias reference?) #:transparent)
(struct cookware (name optional?) #:transparent)
(struct timer (name duration unit) #:transparent)
(struct recipe (name servings metadata ingredients cookware timers steps sections) #:transparent
  #:constructor-name make-recipe)

(define (scale-quantity q factor)
  (if (or (not q) (quantity-locked? q) (not (number? (quantity-value q))))
      q
      (quantity (* (quantity-value q) factor) (quantity-unit q) #f)))

(define (scale-recipe r factor)
  (make-recipe
   (recipe-name r)
   (* (recipe-servings r) factor)
   (recipe-metadata r)
   (map (λ (ing)
          (ingredient (ingredient-name ing)
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

(define-syntax (ingredients stx)
  (syntax-parse stx
    [(_ (name qty opt? hid? ali? ref?) ...)
     #'(list (ingredient name qty opt? hid? ali? ref?) ...)]))

(define-syntax (recipe stx)
  (syntax-parse stx
    [(_ name:string
        (~optional (~seq (servings n:number)) #:defaults ([n #'1]))
        (ingredients ings)
        (steps stps))
     #'(make-recipe name n '() ings '() '() stps '())]))

(define (quantity->sxml q)
  (if (not q) ""
      `(span ,(if (number? (quantity-value q))
                  (number->string (quantity-value q))
                  (~a (quantity-value q)))
             " " ,(or (quantity-unit q) "")
             ,(if (quantity-locked? q) " (fixed)" ""))))

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
    [(string? s) s]
    [(number? s) (number->string s)]
    [(symbol? s) (symbol->string s)]
    [(pair? s)
     (let ([tag (car s)] [body (cdr s)])
       (string-append "<" (symbol->string tag) ">"
                      (string-join (map sxml->html body) "")
                      "</" (symbol->string tag) ">"))]
    [else ""]))

(define (recipe->html r)
  (sxml->html (recipe->sxml r)))
