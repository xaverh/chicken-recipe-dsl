open Ppxlib

(* Minimal parser that recognises Cooklang-like prefixes in the bullet lines *)
let parse_recipe ~loc src =
  let open Ast_builder.Default in
  let lines = src |> String.split_on_char '\n' |> List.map String.trim |> List.filter ((<>) "") in
  let name = List.hd lines in
  let servings =
    try
      List.find (String.starts_with ~prefix:"Servings:") lines
      |> fun s -> float_of_string (String.trim (List.nth (String.split_on_char ':' s) 1))
    with _ -> 1.0
  in
  let rec collect acc = function
    | "Ingredients:" :: rest -> collect_ings [] rest
    | _ :: rest -> collect acc rest
    | [] -> ([], [])
  and collect_ings acc = function
    | line :: rest when String.starts_with ~prefix:"•" line ->
      collect_ings (String.trim (String.sub line 1 (String.length line - 1)) :: acc) rest
    | rest -> (List.rev acc, rest)
  in
  let (ing_lines, after) = collect [] lines in
  let steps =
    let rec go = function
      | "Steps:" :: rest -> rest
      | _ :: rest -> go rest
      | [] -> []
    in
    go after
  in
  let parse_ing line =
    let optional = String.starts_with ~prefix:"?" line in
    let locked = String.starts_with ~prefix:"=" line in
    let clean = if optional || locked then String.sub line 1 (String.length line - 1) |> String.trim else line in
    let parts = String.split_on_char ' ' clean in
    match parts with
    | n :: u :: name_parts ->
      let name = String.concat " " name_parts in
      let qty = [%expr Recipe.Num ([%e efloat ~loc n], [%e estring ~loc u], [%e ebool ~loc locked])] in
      [%expr { Recipe.name = [%e estring ~loc name];
               quantity = [%e qty];
               optional = [%e ebool ~loc optional] }]
    | _ ->
      [%expr { Recipe.name = [%e estring ~loc clean]; quantity = Recipe.Some; optional = false }]
  in
  let ingredients = List.map parse_ing ing_lines in
  let steps_expr = List.map (fun s -> estring ~loc s) steps in
  [%expr
    Recipe.{
      name = [%e estring ~loc name];
      servings = [%e efloat ~loc (string_of_float servings)];
      ingredients = [%e elist ~loc ingredients];
      steps = [%e elist ~loc steps_expr];
    }]

let expander ~loc ~path:_ payload =
  match payload with
  | PStr [{ pstr_desc = Pstr_eval ({ pexp_desc = Pexp_constant (Pconst_string (src, _, _)); _ }, _); _ }] ->
    parse_recipe ~loc src
  | _ -> Location.raise_errorf ~loc "%%recipe expects a string"

let () =
  Driver.register_transformation
    ~impl:(fun str ->
      let rec map_expr e =
        match e.pexp_desc with
        | Pexp_extension ({ txt = "recipe"; _ }, payload) -> expander ~loc:e.pexp_loc ~path:"" payload
        | _ -> Ast_traverse.map_expression map_expr e
      in
      List.map (fun si ->
        match si.pstr_desc with
        | Pstr_value (rf, vbs) ->
          { si with pstr_desc = Pstr_value (rf, List.map (fun vb -> { vb with pvb_expr = map_expr vb.pvb_expr }) vbs) }
        | _ -> si) str)
    "recipe_ppx"
