module Analysis exposing (Token, tokenise, parse)

import String
import Regex exposing (replace, split, regex)


type alias Token =
    { tokenType : String
    , value : String
    , kind : String
    }


tokenise : String -> List Token
tokenise text =
    text
        |> intoStrings
        |> tokeniseStrings


intoStrings : String -> List String
intoStrings text =
    text
        |> replace Regex.All (regex "“|”|\\,|\\.|\\?|\\n") (\{ match } -> "$$" ++ match ++ "$$")
        |> split Regex.All (regex "\\$\\$")
        |> List.filter (\s -> (String.length s) > 0)


tokeniseStrings : List String -> List Token
tokeniseStrings strings =
    strings
        |> List.map tokeniseString


tokeniseString : String -> Token
tokeniseString value =
    case value of
        "“" ->
            Token "Punctuator" value "OpenSpeechMark"

        "”" ->
            Token "Punctuator" value "CloseSpeechMark"

        "," ->
            Token "Punctuator" value ""

        "." ->
            Token "Punctuator" value ""

        "!" ->
            Token "Punctuator" value ""

        "?" ->
            Token "Punctuator" value ""

        "\n" ->
            Token "NewLine" value ""

        _ ->
            Token "Text" value ""



-------------


type alias Leaf =
    { leafType : String
    , body : SyntaxTree
    }


type SyntaxTree
    = SyntaxTree (List Leaf)


parse : String -> Maybe Leaf
parse text =
    Nothing
