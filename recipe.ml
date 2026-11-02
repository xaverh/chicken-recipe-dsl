(* Minimal OCaml model; PPX string uses Cooklang-like prefixes *)

type quantity = Num of float * string * bool | Pinch | Some

type ingredient = {
  name : string;
  quantity : quantity;
  optional : bool;
}

type recipe = {
  name : string;
  servings : float;
  ingredients : ingredient list;
  steps : string list;
}

let scale_quantity q f =
  match q with
  | Num (n, u, false) -> Num (n *. f, u, false)
  | other -> other

let scale_recipe r f =
  { r with
    servings = r.servings *. f;
    ingredients = List.map (fun i -> { i with quantity = scale_quantity i.quantity f }) r.ingredients }

let recipe_to_html r =
  let ings = String.concat "" (List.map (fun i ->
    let opt = if i.optional then "(optional) " else "" in
    let qstr = match i.quantity with
      | Num (n, u, _) -> Printf.sprintf "%.0f %s" n u
      | Pinch -> "pinch"
      | Some -> "some" in
    Printf.sprintf "<li>%s%s: %s</li>" opt i.name qstr) r.ingredients) in
  let stps = String.concat "" (List.map (Printf.sprintf "<li>%s</li>") r.steps) in
  Printf.sprintf "<article><h1>%s</h1><p>Servings: %.0f</p><h2>Ingredients</h2><ul>%s</ul><h2>Steps</h2><ol>%s</ol></article>"
    r.name r.servings ings stps
