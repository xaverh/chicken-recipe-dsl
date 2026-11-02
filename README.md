# Recipe DSL — JavaScript branch

Uses a tagged-template / builder style and a small helper to approximate the original surface.

## Surface

```js
const r = recipe`Spaghetti al pomodoro`
  .servings(4)
  .ingredients(
    ing`spaghetti`(g(500)),
    ing`tomato purée`(ml(250)),
    ing`salt`(pinch)
  )
  .steps(
    "Boil the pasta.",
    "Heat the sauce."
  );
```
