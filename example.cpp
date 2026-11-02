#include "recipe.hpp"
#include <iostream>

// Pure recipe definition
auto make_spaghetti() {
  return RECIPE("Spaghetti al pomodoro",
    SERVINGS(4),
    INGREDIENTS(
      ING("spaghetti", G(500)),
      ING("tomato purée", ML(250)),
      ING("salt", PINCH),
      ING("basil", G(10))
    ),
    STEPS(
      "Bring a large pot of water to a boil and salt it.",
      "Cook the spaghetti according to package directions.",
      "Heat the tomato purée in a pan.",
      "Drain the pasta and combine with the sauce.",
      "Season and serve with fresh basil."
    )
  );
}

// Demo / driver code (not part of the recipe)
int main() {
  auto spaghetti = make_spaghetti();
  std::cout << "Original:\n" << recipe_to_html(spaghetti) << "\n";
  std::cout << "\n--- Scaled to 2x ---\n" << recipe_to_html(scale_recipe(spaghetti, 2.0)) << "\n";
}
