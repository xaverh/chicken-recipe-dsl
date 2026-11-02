# Recipe DSL — C++ branch

Uses preprocessor macros to approximate the original surface syntax.

## Surface

```cpp
auto r = RECIPE("Spaghetti al pomodoro",
  SERVINGS(4),
  INGREDIENTS(
    ING("spaghetti", G(500)),
    ING("tomato purée", ML(250)),
    ING("salt", PINCH)
  ),
  STEPS(
    "Boil the pasta.",
    "Heat the sauce."
  )
);
```
