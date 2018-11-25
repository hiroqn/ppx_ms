let test =
  QCheck.Test.make ~count:20 ~name:"hours test"
   QCheck.(small_nat)
   (fun n -> Ppx_ms_parser.parse (string_of_int n ^ "hours") = Result.Ok (n * 60 * 60 * 1000));;

QCheck_runner.run_tests [test];;
