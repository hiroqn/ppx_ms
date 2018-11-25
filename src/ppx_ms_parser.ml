open Angstrom

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

let parse query =
    parse_only expression (`String query)
