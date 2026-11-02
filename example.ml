open Recipe

(* Pure recipe with Cooklang features *)
let spaghetti = {
  name = "Spaghetti al pomodoro";
  servings = 4.0;
  metadata = [];
  ingredients = [
    { name = "spaghetti"; quantity = g 500.0; optional = false; hidden = false; alias = None; reference = false };
    { name = "tomato purée"; quantity = ml 250.0; optional = false; hidden = false; alias = None; reference = false };
    { name = "salt"; quantity = locked (Num (1.0, "pinch", false)); optional = false; hidden = false; alias = None; reference = false };
    { name = "basil"; quantity = g 10.0; optional = true; hidden = false; alias = None; reference = false };
  ];
  cookware = [];
  timers = [];
  steps = [
    "Bring a large pot of water to a boil and salt it.";
    "Cook the spaghetti according to package directions.";
    "Heat the tomato purée in a pan.";
    "Drain the pasta and combine with the sauce.";
    "Season and serve with fresh basil.";
  ];
  sections = [];
}
