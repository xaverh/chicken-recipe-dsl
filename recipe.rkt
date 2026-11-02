#lang racket/base

(require (for-syntax racket/base
                     syntax/parse)
         racket/contract
         racket/string)

(provide (contract-out
          [recipe? predicate/c]
          [scale-recipe (-> recipe? real? recipe?)]
          [recipe->sxml (-> recipe? any/c)]
          [recipe->html (-> recipe? string?)])
         recipe)

;; Data
(struct recipe (name servings ingredients steps)
  #:transparent
  #:constructor-name make-recipe)

;; Quantities: (list unit amount) or symbol
(define (quantity-numeric? q)
  (and (pair? q) (number? (cadr q))))

(define (scale-quantity q factor)
  (cond
    [(quantity-numeric? q)
     (list (car q) (* (cadr q) factor))]
    [else q]))

(define (scale-recipe r factor)
  (make-recipe
   (recipe-name r)
   (* (recipe-servings r) factor)
   (map (lambda (ing)
          (cons (car ing)
                (scale-quantity (cdr ing) factor)))
        (recipe-ingredients r))
   (recipe-steps r)))

;; Syntax classes for better errors
(begin-for-syntax
  (define-syntax-class quantity
    #:description "quantity (unit number) or special"
    (pattern (unit:id n:number)
             #:fail-when (and (real? (syntax-e #'n))
                              (negative? (syntax-e #'n)))
             "quantity cannot be negative")
    (pattern pinch)
    (pattern to-taste))

  (define-syntax-class ingredient
    #:description "ingredient (name quantity)"
    (pattern (name:string q:quantity))))

;; Macros with syntax-parse
(define-syntax (ingredients stx)
  (syntax-parse stx
    [(_ ing:ingredient ...)
     #'(list (cons ing.name (quote ing.q)) ...)]
    [(_ other ...)
     (raise-syntax-error #f "expected (name quantity) pairs" stx)]))

(define-syntax (steps stx)
  (syntax-parse stx
    [(_ s:string ...)
     #'(list s ...)]
    [(_ other ...)
     (raise-syntax-error #f "expected strings" stx)]))

(define-syntax (recipe stx)
  (syntax-parse stx
    [(_ name:string
        (~optional (~seq (servings n:number)) #:defaults ([n #'1]))
        (ingredients ings)
        (steps stps))
     #'(make-recipe name n ings stps)]
    [(_ other ...)
     (raise-syntax-error #f
                         "expected (recipe name [ (servings N) ] (ingredients ...) (steps ...))"
                         stx)]))

;; SXML / HTML
(define (quantity->sxml q)
  (cond
    [(quantity-numeric? q)
     `(span ,(number->string (cadr q)) " " ,(symbol->string (car q)))]
    [(symbol? q)
     `(span ,(symbol->string q))]
    [else
     `(span ,(format "~a" q))]))

(define (ingredient->sxml ing)
  `(li ,(car ing) ": " ,(quantity->sxml (cdr ing))))

(define (recipe->sxml r)
  `(article
     (h1 ,(recipe-name r))
     (p "Servings: " ,(number->string (recipe-servings r)))
     (h2 "Ingredients")
     (ul ,@(map ingredient->sxml (recipe-ingredients r)))
     (h2 "Steps")
     (ol ,@(map (lambda (s) `(li ,s)) (recipe-steps r)))))

(define (sxml->html s)
  (cond
    [(string? s) s]
    [(number? s) (number->string s)]
    [(symbol? s) (symbol->string s)]
    [(pair? s)
     (let ([tag (car s)]
           [body (cdr s)])
       (string-append
        "<" (symbol->string tag) ">"
        (string-join (map sxml->html body) "")
        "</" (symbol->string tag) ">"))]
    [else ""]))

(define (recipe->html r)
  (sxml->html (recipe->sxml r)))
