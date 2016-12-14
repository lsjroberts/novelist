module Token.Utils exposing (..)

import Regex
import Token.Types exposing (..)


wrap char =
    wrap2 char char


wrap2 : String -> String -> (String -> Model) -> (String -> Model) -> String -> List Model
wrap2 left right inside outside string =
    let
        exp =
            Regex.regex (left ++ ".+?" ++ right)

        insides =
            Regex.find Regex.All exp string
                |> List.map .match
                |> List.map inside

        outsides =
            Regex.split Regex.All exp string
                |> List.map outside
                |> filterEmptyTextTokens
    in
        if String.startsWith left string then
            zip insides outsides
        else
            zip outsides insides


filterEmptyParagraphTokens : List Model -> List Model
filterEmptyParagraphTokens =
    List.filter
        (\x ->
            if x.token == Paragraph then
                if List.length (filterEmptyTextTokens (children x)) == 0 then
                    True
                else
                    True
            else
                True
        )


filterEmptyTextTokens : List Model -> List Model
filterEmptyTextTokens =
    List.filter
        (\x ->
            case x.token of
                Text value ->
                    if String.length value > 0 then
                        True
                    else
                        False

                _ ->
                    False
        )


zip : List Model -> List Model -> List Model
zip xs ys =
    case ( xs, ys ) of
        ( x :: xBack, y :: yBack ) ->
            [ x, y ] ++ zip xBack yBack

        ( x :: xBack, _ ) ->
            [ x ]

        ( _, y :: yBack ) ->
            [ y ]

        ( _, _ ) ->
            []
