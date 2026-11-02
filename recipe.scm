(module recipe
  (recipe scale-recipe recipe->sxml recipe->html
   recipe? recipe-name recipe-servings recipe-ingredients recipe-steps)

  (import scheme
          (chicken base)
          (chicken syntax)
          (chicken condition)
          (chicken port)
          srfi-1)

  ;; Allow the actual λ character as a synonym for lambda
  (define-syntax λ
    (syntax-rules ()
      ((_ . rest) (lambda . rest))))

  ;; Records
  (define-record-type recipe
    (make-recipe name servings ingredients steps)
    recipe?
    (name recipe-name)
    (servings recipe-servings)
    (ingredients recipe-ingredients)
    (steps recipe-steps))

  ;; Helpers for quantities
  (define (quantity-numeric? q)
    (and (pair? q) (number? (cadr q))))

  (define (scale-quantity q factor)
    (cond
      ((quantity-numeric? q)
       (list (car q) (* (cadr q) factor)))
      (else q)))  ; pinch, to-taste, etc. stay the same

  ;; Scaling
  (define (scale-recipe r factor)
    (make-recipe
      (recipe-name r)
      (* (recipe-servings r) factor)
      (map (λ (ing)
             (cons (car ing)
                   (scale-quantity (cdr ing) factor)))
           (recipe-ingredients r))
      (recipe-steps r)))

  ;; Macro: ingredients
  (define-syntax ingredients
    (er-macro-transformer
     (λ (form rename compare)
       (let ((pairs (cdr form)))
         (unless (every (λ (p)
                          (and (list? p)
                               (= (length p) 2)
                               (string? (car p))))
                        pairs)
           (syntax-error 'ingredients
                         "expected (\"name\" quantity) pairs"
                         form))
         `(list ,@(map (λ (p)
                         `(cons ,(car p) ,(cadr p)))
                       pairs))))))

  ;; Macro: steps (just collect strings)
  (define-syntax steps
    (syntax-rules ()
      ((_ s ...)
       (list s ...))))

  ;; Macro: recipe
  (define-syntax recipe
    (er-macro-transformer
     (λ (form rename compare)
       (let ((name (cadr form))
             (rest (cddr form)))
         ;; very simple extraction — improve later
         (let loop ((rest rest)
                    (servings 1)
                    (ings '())
                    (stps '()))
           (if (null? rest)
               `(make-recipe ,name ,servings ,ings ,stps)
               (let ((clause (car rest)))
                 (cond
                   ((and (pair? clause) (eq? (car clause) 'servings))
                    (loop (cdr rest) (cadr clause) ings stps))
                   ((and (pair? clause) (eq? (car clause) 'ingredients))
                    (loop (cdr rest) servings (cadr clause) stps))
                   ((and (pair? clause) (eq? (car clause) 'steps))
                    (loop (cdr rest) servings ings (cadr clause)))
                   (else
                    (syntax-error 'recipe "unknown clause" clause))))))))))

  ;; SXML generation (simple)
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

  ;; Very simple HTML emitter (no escaping for skeleton)
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
          (string-concatenate (map sxml->html body))
          "</" (symbol->string tag) ">")))
      (else "")))

  (define (recipe->html r)
    (sxml->html (recipe->sxml r)))

  ) ; end module
