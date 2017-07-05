module Utils.List exposing (..)


getById : List { a | id : Int } -> Int -> Maybe { a | id : Int }
getById xs id =
    xs
        |> List.filter (\x -> x.id == id)
        |> List.head
