#include "recipe.hpp"
#include <iostream>

int main() {
  Recipe spaghetti{
    "Spaghetti al pomodoro",
    4.0,
    {
      {"spaghetti", {500.0, "g"}},
      {"tomato purée", {250.0, "ml"}},
      {"salt", {"pinch", ""}},
      {"basil", {10.0, "g"}}
    },
    {
      "Bring a large pot of water to a boil and salt it.",
      "Cook the spaghetti according to package directions.",
      "Heat the tomato purée in a pan.",
      "Drain the pasta and combine with the sauce.",
      "Season and serve with fresh basil."
    }
  };

  std::cout << "Original:\n" << recipe_to_html(spaghetti) << "\n";
  std::cout << "\n--- Scaled to 2x ---\n" << recipe_to_html(scale_recipe(spaghetti, 2.0)) << "\n";
}
