open Ppxlib

let expander ~loc ~path:_ payload =
  let open Ast_builder.Default in
  match payload with
  | PStr [{
      pstr_desc = Pstr_eval (
        { pexp_desc = Pexp_tuple
            [ { pexp_desc = Pexp_constant (Pconst_string (name, _, _)); _ }
            ; servings_expr
            ; ingredients_expr
            ; steps_expr
            ]
        ; _ }
      , _)
    ; _ }]
    ->
    (* Very simplified parser — expects the four-tuple form produced by the surface.
       In a real PPX you would walk a custom AST; this is a skeleton. *)
    let servings =
      match servings_expr.pexp_desc with
      | Pexp_apply ({ pexp_desc = Pexp_ident { txt = Lident "servings"; _ }; _ },
                    [Nolabel, { pexp_desc = Pexp_constant (Pconst_float (n, _)); _ }])
        -> efloat ~loc n
      | _ -> efloat ~loc "1.0"
    in
    [%expr
      Recipe.{
        name = [%e estring ~loc name];
        servings = [%e servings];
        ingredients = [%e ingredients_expr];
        steps = [%e steps_expr];
      }]
  | _ ->
    Location.raise_errorf ~loc "%%recipe expects (name (servings N) (ingredients ...) (steps ...))"

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
