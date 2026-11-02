# Racket vs Chicken for this recipe DSL

## Concrete advantages of the Racket version

### 1. Better error messages (syntax-parse)
Try this in the Racket version:

```racket
(ingredients ("salt" (g -5)))
```

You get a clear message: “quantity cannot be negative” pointing at the bad form.

In the Chicken version the same check is possible but requires more manual code and the message is less automatically integrated with the source location machinery.

### 2. Cleaner, more declarative macros
The `recipe` form in Racket uses `~optional` and pattern matching. Adding a new optional clause is a one-line change. The Chicken version uses an explicit loop over clauses.

### 3. Contracts on the public API
`scale-recipe` and `recipe->html` are protected by contracts. Call them with the wrong type and you get a clear contract violation with blame. Chicken has no equivalent out of the box.

### 4. Path to a real `#lang`
The Racket code is already structured so you can wrap it in a language module and write:

```racket
#lang s-exp "recipe-lang.rkt"

(recipe "Pasta" ...)
```

or a full custom reader. Chicken has no comparable first-class language mechanism.

### 5. Tooling
Open `example.rkt` in DrRacket: syntax highlighting, indentation, error arrows, and the ability to expand macros interactively all work. The Chicken version relies on an external editor + `csi`.

### 6. Publishing path
The SXML is identical, but Racket can drop the same data into Scribble with almost no extra work for a multi-page, cross-referenced cookbook that also emits PDF. Chicken needs more custom tooling for the same result.

## What stays the same
- The surface syntax you originally sketched
- Scaling logic
- SXML/HTML generation
- Overall data model

The Racket version is not dramatically shorter, but it is more robust, more extensible, and better supported by the surrounding language and tools.
