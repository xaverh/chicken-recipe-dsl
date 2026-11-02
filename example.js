import { makeRecipe, scaleRecipe, recipeToHtml } from './recipe.js';

const spaghetti = makeRecipe(
  "Spaghetti al pomodoro",
  4,
  [
    ["spaghetti", ["g", 500]],
    ["tomato purée", ["ml", 250]],
    ["salt", "pinch"],
    ["basil", ["g", 10]]
  ],
  [
    "Bring a large pot of water to a boil and salt it.",
    "Cook the spaghetti according to package directions.",
    "Heat the tomato purée in a pan.",
    "Drain the pasta and combine with the sauce.",
    "Season and serve with fresh basil."
  ]
);

console.log("Original:");
console.log(recipeToHtml(spaghetti));
console.log("\n--- Scaled to 2x ---");
console.log(recipeToHtml(scaleRecipe(spaghetti, 2)));
