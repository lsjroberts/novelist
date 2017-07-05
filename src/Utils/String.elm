module Utils.String exposing (..)

import Char


getStringWordCount : String -> Int
getStringWordCount =
    String.split " "
        >> List.filter (isSpaceChar >> not)
        >> List.filter isAlphaNumericChar
        >> List.length


isSpaceChar : String -> Bool
isSpaceChar char =
    case char of
        "\n" ->
            True

        _ ->
            False


isAlphaNumericChar : String -> Bool
isAlphaNumericChar string =
    let
        char =
            case String.uncons string of
                Just ( c, rest ) ->
                    c

                Nothing ->
                    ' '

        code =
            Char.toCode char
    in
        if
            (code >= 48 && code <= 57)
                || (code >= 65 && code <= 90)
                || (code >= 97 && code <= 122)
        then
            True
        else
            False
