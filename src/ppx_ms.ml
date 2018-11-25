module From_current = Migrate_parsetree.Convert(Migrate_parsetree.OCaml_current)(Migrate_parsetree.OCaml_402)
module To_current = Migrate_parsetree.Convert(Migrate_parsetree.OCaml_402)(Migrate_parsetree.OCaml_current)

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
            match Ppx_ms_parser.parse query with
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
