#pragma once
#include <string>
#include <vector>
#include <variant>
#include <sstream>
#include <algorithm>

struct Quantity {
  std::variant<double, std::string> value; // number or "pinch" etc.
  std::string unit;
};

struct Ingredient {
  std::string name;
  Quantity quantity;
};

struct Recipe {
  std::string name;
  double servings = 1.0;
  std::vector<Ingredient> ingredients;
  std::vector<std::string> steps;
};

inline Quantity scale_quantity(const Quantity& q, double factor) {
  if (std::holds_alternative<double>(q.value))
    return {std::get<double>(q.value) * factor, q.unit};
  return q;
}

inline Recipe scale_recipe(const Recipe& r, double factor) {
  Recipe out = r;
  out.servings *= factor;
  for (auto& ing : out.ingredients)
    ing.quantity = scale_quantity(ing.quantity, factor);
  return out;
}

inline std::string quantity_to_string(const Quantity& q) {
  if (std::holds_alternative<double>(q.value))
    return std::to_string(static_cast<int>(std::get<double>(q.value))) + " " + q.unit;
  return std::get<std::string>(q.value);
}

inline std::string recipe_to_html(const Recipe& r) {
  std::ostringstream oss;
  oss << "<article><h1>" << r.name << "</h1>"
      << "<p>Servings: " << static_cast<int>(r.servings) << "</p>"
      << "<h2>Ingredients</h2><ul>";
  for (const auto& ing : r.ingredients)
    oss << "<li>" << ing.name << ": " << quantity_to_string(ing.quantity) << "</li>";
  oss << "</ul><h2>Steps</h2><ol>";
  for (const auto& s : r.steps)
    oss << "<li>" << s << "</li>";
  oss << "</ol></article>";
  return oss.str();
}
