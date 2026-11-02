open Ppxlib

(* Simple line-based parser for a natural recipe format.
   This is a skeleton; a production version would use a proper parser combinator. *)

let parse_recipe ~loc src =
  let open Ast_builder.Default in
  let lines =
    src
    |> String.split_on_char '\n'
    |> List.map String.trim
    |> List.filter (fun s -> s <> "")
  in
  let rec parse_name = function
    | name :: rest -> (name, rest)
    | [] -> Location.raise_errorf ~loc "empty recipe"
  in
  let rec parse_servings acc = function
    | line :: rest when String.starts_with ~prefix:"Servings:" line ->
      let n = line |> String.split_on_char ':' |> List.tl |> String.concat ":" |> String.trim |> float_of_string in
      (n, rest)
    | rest -> (1.0, rest)
  in
  let rec parse_section header acc = function
    | line :: rest when String.lowercase_ascii line = header ->
      parse_items rest
    | _ :: rest -> parse_section header acc rest
    | [] -> (List.rev acc, [])
  and parse_items = function
    | line :: rest when String.starts_with ~prefix:"-" line || String.starts_with ~prefix:"1." line || String.starts_with ~prefix:"2." line || String.starts_with ~prefix:"3." line || String.starts_with ~prefix:"4." line || String.starts_with ~prefix:"5." line || String.starts_with ~prefix:"6." line || String.starts_with ~prefix:"7." line || String.starts_with ~prefix:"8." line || String.starts_with ~prefix:"9." line ->
      let item = line |> String.trim |> (fun s ->
        if String.starts_with ~prefix:"-" s then String.sub s 1 (String.length s - 1) |> String.trim
        else
          try
            let idx = String.index s '.' in
            String.sub s (idx + 1) (String.length s - idx - 1) |> String.trim
          with Not_found -> s
      ) in
      let (items, rest') = parse_items rest in
      (item :: items, rest')
    | rest -> ([], rest)
  in
  let (name, rest1) = parse_name lines in
  let (servings, rest2) = parse_servings 1.0 rest1 in
  let (ing_lines, rest3) = parse_section "ingredients:" [] rest2 in
  let (step_lines, _) = parse_section "steps:" [] rest3 in
  (* Very rough quantity parsing for the skeleton *)
  let parse_ing line =
    let parts = String.split_on_char ' ' line in
    match parts with
    | n :: unit :: name_parts when unit = "g" || unit = "ml" ->
      let name = String.concat " " name_parts in
      let qty =
        if unit = "g" then [%expr Recipe.G [%e efloat ~loc n]]
        else [%expr Recipe.Ml [%e efloat ~loc n]]
      in
      [%expr ([%e estring ~loc name], [%e qty])]
    | "pinch" :: name_parts ->
      let name = String.concat " " name_parts in
      [%expr ([%e estring ~loc name], Recipe.Pinch)]
    | _ ->
      [%expr ([%e estring ~loc line], Recipe.ToTaste)]
  in
  let ingredients = List.map parse_ing ing_lines in
  let steps = List.map (fun s -> estring ~loc s) step_lines in
  [%expr
    Recipe.{
      name = [%e estring ~loc name];
      servings = [%e efloat ~loc (string_of_float servings)];
      ingredients = [%e elist ~loc ingredients];
      steps = [%e elist ~loc steps];
    }]

let expander ~loc ~path:_ payload =
  match payload with
  | PStr [{
      pstr_desc = Pstr_eval (
        { pexp_desc = Pexp_constant (Pconst_string (src, _, _)); _ }
      , _)
    ; _ }]
    -> parse_recipe ~loc src
  | _ ->
    Location.raise_errorf ~loc "%%recipe expects a string literal containing the recipe"

let () =
  Driver.register_transformation
    ~impl:(fun str ->
      let rec map_expr e =
        match e.pexp_desc with
        | Pexp_extension ({ txt = "recipe"; _ }, payload) ->
          expander ~loc:e.pexp_loc ~path:"" payload
        | _ ->
          Ast_traverse.map_expression map_expr e
      in
      List.map (fun si ->
        match si.pstr_desc with
        | Pstr_eval (e, attrs) ->
          { si with pstr_desc = Pstr_eval (map_expr e, attrs) }
        | Pstr_value (rf, vbs) ->
          { si with pstr_desc =
              Pstr_value (rf,
                List.map (fun vb ->
                  { vb with pvb_expr = map_expr vb.pvb_expr }) vbs) }
        | _ -> si
      ) str)
    "recipe_ppx"
