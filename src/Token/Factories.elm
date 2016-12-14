module Token.Factories exposing (..)

import Regex
import Token.Types exposing (..)
import Token.Utils exposing (..)


markdownToTokens : String -> List Model
markdownToTokens string =
    let
        cleanString =
            Regex.replace Regex.All (Regex.regex "\n+$") (\_ -> "") string

        tokens =
            if String.contains "\n" cleanString then
                cleanString
                    |> String.split "\n"
                    |> List.map paragraph
            else if String.contains "“" cleanString then
                wrap2 "“" "”" speech text string
            else if String.contains "\"" cleanString then
                wrap "\"" speech text string
            else if String.contains "_" cleanString then
                wrap "_" emphasis text cleanString
            else
                [ text cleanString ]
    in
        tokens |> filterEmptyParagraphTokens


paragraph : String -> Model
paragraph string =
    Model Paragraph (Children (markdownToTokens string))


speech : String -> Model
speech string =
    string
        |> Regex.replace Regex.All (Regex.regex "“|”|\"") (\_ -> "")
        |> markdownToTokens
        |> Children
        |> Model Speech


emphasis : String -> Model
emphasis string =
    string
        |> Regex.replace Regex.All (Regex.regex "_") (\_ -> "")
        |> markdownToTokens
        |> Children
        |> Model Emphasis


text : String -> Model
text string =
    Model (Text string) (Children [])
