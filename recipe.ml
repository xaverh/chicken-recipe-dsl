(* OCaml recipe DSL — combinator-style surface approximating macros *)

type quantity =
  | G of float
  | Ml of float
  | Pinch
  | ToTaste

type clause =
  | Servings of float
  | Ingredients of (string * quantity) list
  | Steps of string list

type recipe = {
  name : string;
  servings : float;
  ingredients : (string * quantity) list;
  steps : string list;
}

let g n = G n
let ml n = Ml n
let pinch = Pinch
let to_taste = ToTaste

let servings n = Servings n
let ingredients xs = Ingredients xs
let steps xs = Steps xs

let recipe name clauses =
  let servings = ref 1.0 in
  let ings = ref [] in
  let stps = ref [] in
  List.iter (function
    | Servings n -> servings := n
    | Ingredients xs -> ings := xs
    | Steps xs -> stps := xs
  ) clauses;
  { name; servings = !servings; ingredients = !ings; steps = !stps }

let scale_quantity q factor =
  match q with
  | G n -> G (n *. factor)
  | Ml n -> Ml (n *. factor)
  | Pinch | ToTaste -> q

let scale_recipe r factor =
  { r with
    servings = r.servings *. factor;
    ingredients = List.map (fun (n, q) -> (n, scale_quantity q factor)) r.ingredients
  }

let quantity_to_string = function
  | G n -> Printf.sprintf "%.0f g" n
  | Ml n -> Printf.sprintf "%.0f ml" n
  | Pinch -> "pinch"
  | ToTaste -> "to taste"

let recipe_to_html r =
  let ings = String.concat "" (List.map (fun (n, q) ->
    Printf.sprintf "<li>%s: %s</li>" n (quantity_to_string q)) r.ingredients) in
  let stps = String.concat "" (List.map (fun s ->
    Printf.sprintf "<li>%s</li>" s) r.steps) in
  Printf.sprintf
    "<article><h1>%s</h1><p>Servings: %.0f</p><h2>Ingredients</h2><ul>%s</ul><h2>Steps</h2><ol>%s</ol></article>"
    r.name r.servings ings stps
