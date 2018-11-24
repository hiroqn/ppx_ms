open Angstrom

module From_current = Migrate_parsetree.Convert(Migrate_parsetree.OCaml_current)(Migrate_parsetree.OCaml_402)
module To_current = Migrate_parsetree.Convert(Migrate_parsetree.OCaml_402)(Migrate_parsetree.OCaml_current)

let integer =
  take_while1 (function '0' .. '9' -> true | _ -> false) >>| int_of_string >>| ( * )

let space = skip_many @@ char ' '

let joinWithOr ls = match List.map string ls with
  | a :: l -> l |> List.fold_left (<|>) a
  | _ -> fail "Wow"

let milliseconds = joinWithOr ["milliseconds"; "millisecond"; "msecs"; "msec"; "ms"] *> return 1

let seconds = joinWithOr ["seconds"; "second"; "secs"; "sec"; "s"]  *> return 1000

let minutes = joinWithOr ["minutes"; "minute"; "mins"; "min"; "m"] *> return (60 * 1000)

let hours = joinWithOr ["hours"; "hour"; "hrs"; "hr"; "h"] *> return (60 * 60 * 1000)

let days = joinWithOr ["days"; "day"; "d";] *> return (24 * 60 * 60 * 1000)

let weeks = joinWithOr ["weeks"; "week"; "w";] *> return (7 * 24 * 60 * 60 * 1000)

let years = joinWithOr ["years"; "year"; "yrs"; "yr"; "y";] *> return (365 * 7 * 24 * 60 * 60 * 1000)

let expression =
  fix(fun expr ->
    ((+) <$> (integer
      <*> (years <|> weeks <|> hours <|> milliseconds <|> minutes <|> seconds))
      <*> (space *> expr))
    <|> (end_of_input *> return 0) )

let mapper _ =
  let open Migrate_parsetree in
  let open Ast_402 in
  let open Ast_mapper in
  let open Parsetree in
  let open Asttypes in
  let expr mapper = function
    | { pexp_desc = Pexp_extension ({ txt = "ms" }, pstr); pexp_loc; } ->
      begin match pstr with
        | PStr [{
            pstr_desc = Pstr_eval ({
              pexp_desc = Pexp_constant (Const_string (query, None))
            }, _)
          }] ->
          begin
            match parse_only expression (`String query) with
            | Result.Ok n ->
              {
                pexp_desc = Pexp_constant (Const_int n);
                pexp_attributes = [];
                pexp_loc;
              }
            | Result.Error msg -> failwith msg
          end
        | _ -> failwith "Not supported exp"
      end
    | other -> default_mapper.expr mapper other in
  To_current.copy_mapper { default_mapper with expr }

let () = Migrate_parsetree.Compiler_libs.Ast_mapper.register "ms" mapper
