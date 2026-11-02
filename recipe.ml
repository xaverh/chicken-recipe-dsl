(* OCaml recipe with Cooklang MVP features *)

type quantity =
  | Num of float * string * bool  (* value, unit, locked *)
  | Range of float * float * string * bool
  | Some
  | Pinch
  | ToTaste

type ingredient = {
  name : string;
  quantity : quantity;
  optional : bool;
  hidden : bool;
  alias : string option;
  reference : bool;
}

type cookware = {
  name : string;
  optional : bool;
}

type timer = {
  name : string option;
  duration : float;
  unit : string;
}

type recipe = {
  name : string;
  servings : float;
  metadata : (string * string) list;
  ingredients : ingredient list;
  cookware : cookware list;
  timers : timer list;
  steps : string list;
  sections : string list;
}

let g n = Num (n, "g", false)
let ml n = Num (n, "ml", false)
let pinch = Pinch
let locked q =
  match q with
  | Num (n, u, _) -> Num (n, u, true)
  | other -> other

let scale_quantity q factor =
  match q with
  | Num (n, u, false) -> Num (n *. factor, u, false)
  | Range (a, b, u, false) -> Range (a *. factor, b *. factor, u, false)
  | other -> other

let scale_recipe r factor =
  { r with
    servings = r.servings *. factor;
    ingredients = List.map (fun ing ->
      { ing with quantity = scale_quantity ing.quantity factor }) r.ingredients
  }

let quantity_to_string = function
  | Num (n, u, locked) ->
    Printf.sprintf "%s%.0f %s" (if locked then "=" else "") n u
  | Range (a, b, u, _) -> Printf.sprintf "%.0f-%.0f %s" a b u
  | Some -> "some"
  | Pinch -> "pinch"
  | ToTaste -> "to taste"

let recipe_to_html r =
  let ings = String.concat "" (List.map (fun ing ->
    let opt = if ing.optional then "(optional) " else "" in
    let name = Option.value ing.alias ~default:ing.name in
    Printf.sprintf "<li>%s%s: %s</li>" opt name (quantity_to_string ing.quantity)
  ) r.ingredients) in
  let stps = String.concat "" (List.map (fun s -> Printf.sprintf "<li>%s</li>" s) r.steps) in
  Printf.sprintf
    "<article><h1>%s</h1><p>Servings: %.0f</p><h2>Ingredients</h2><ul>%s</ul><h2>Steps</h2><ol>%s</ol></article>"
    r.name r.servings ings stps
