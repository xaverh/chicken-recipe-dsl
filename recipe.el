;;; recipe.el --- Recipe DSL for Emacs Lisp  -*- lexical-binding: t; -*-

(require 'cl-lib)

;; λ synonym
(defmacro λ (args &rest body)
  `(lambda ,args ,@body))

;; Struct
(cl-defstruct recipe
  name
  (servings 1)
  ingredients
  steps)

;; Helpers
(defun quantity-numeric-p (q)
  (and (consp q) (numberp (cadr q))))

(defun scale-quantity (q factor)
  (cond
   ((quantity-numeric-p q)
    (list (car q) (* (cadr q) factor)))
   (t q)))

(defun scale-recipe (r factor)
  (make-recipe
   :name (recipe-name r)
   :servings (* (recipe-servings r) factor)
   :ingredients (mapcar (λ (ing)
                          (cons (car ing)
                                (scale-quantity (cdr ing) factor)))
                        (recipe-ingredients r))
   :steps (recipe-steps r)))

;; Macros
(defmacro ingredients (&rest pairs)
  `(list ,@(mapcar (λ (p) `(cons ,(car p) ',(cadr p))) pairs)))

(defmacro steps (&rest strs)
  `(list ,@strs))

(defmacro recipe (name &rest args)
  `(make-recipe :name ,name ,@args))

;; SXML / HTML
(defun quantity->sxml (q)
  (cond
   ((quantity-numeric-p q)
    `(span ,(number-to-string (cadr q)) " " ,(symbol-name (car q))))
   ((symbolp q)
    `(span ,(symbol-name q)))
   (t
    `(span ,(format "%s" q)))))

(defun ingredient->sxml (ing)
  `(li ,(car ing) ": " ,(quantity->sxml (cdr ing))))

(defun recipe->sxml (r)
  `(article
     (h1 ,(recipe-name r))
     (p "Servings: " ,(number-to-string (recipe-servings r)))
     (h2 "Ingredients")
     (ul ,@(mapcar #'ingredient->sxml (recipe-ingredients r)))
     (h2 "Steps")
     (ol ,@(mapcar (λ (s) `(li ,s)) (recipe-steps r)))))

(defun sxml->html (s)
  (cond
   ((stringp s) s)
   ((numberp s) (number-to-string s))
   ((symbolp s) (symbol-name s))
   ((consp s)
    (let ((tag (car s))
          (body (cdr s)))
      (concat
       "<" (symbol-name tag) ">"
       (mapconcat #'sxml->html body "")
       "</" (symbol-name tag) ">")))
   (t "")))

(defun recipe->html (r)
  (sxml->html (recipe->sxml r)))

(provide 'recipe)
;;; recipe.el ends here
