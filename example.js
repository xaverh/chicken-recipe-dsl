import { recipe, g, ml, pinch, ing } from './recipe.js';

// Pure recipe definition
export const spaghetti = recipe`Spaghetti al pomodoro`
  .servings(4)
  .ingredients(
    ing`spaghetti`(g(500)),
    ing`tomato purée`(ml(250)),
    ing`salt`(pinch),
    ing`basil`(g(10))
  )
  .steps(
    "Bring a large pot of water to a boil and salt it.",
    "Cook the spaghetti according to package directions.",
    "Heat the tomato purée in a pan.",
    "Drain the pasta and combine with the sauce.",
    "Season and serve with fresh basil."
  )
  .build();
