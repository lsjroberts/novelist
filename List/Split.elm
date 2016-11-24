module List.Split exposing (splitWith)

-- https://groups.google.com/d/msg/elm-discuss/CvuDaBPYjBc/z6o56AF2BAAJ


splitWith : (a -> Bool) -> List a -> List (List a)
splitWith with list =
    List.foldr
        (\next total ->
            case total of
                [] ->
                    if with next then
                        []
                    else
                        [ next ] :: total

                first :: rest ->
                    if with next then
                        [] :: total
                    else
                        (next :: first) :: rest
        )
        []
        list



-- flattenWith : (a -> b -> b) -> (a -> Bool) -> b -> List a -> List b
-- flattenWith flatten with initial list =
--   List.foldr
--     (\next total ->
--       if
--     )
--     initial
--     list
-- main =
--   ["a","b","c","d","e","f","g","h","i","j"]
--     |> flattenWithWhen (++) ((==) "e")
--     |> text
