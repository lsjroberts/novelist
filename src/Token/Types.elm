module Token.Types exposing (..)

import Regex


type alias Model =
    { token : TokenType
    , value : String
    , children : Children
    }


type TokenType
    = Text
    | Paragraph
    | Speech


type Children
    = Children (List Model)


type Msg
    = NoOp



-- FACTORIES


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
            else if String.contains "“" string then
                wrap2 "“" "”" speech text string
            else if String.contains "\"" string then
                wrap "\"" speech text string
            else
                [ text cleanString ]
    in
        tokens |> filterEmptyParagraphTokens


wrap char =
    wrap2 char char


wrap2 : String -> String -> (String -> Model) -> (String -> Model) -> String -> List Model
wrap2 left right inside outside string =
    let
        exp =
            Regex.regex (left ++ ".+?" ++ right)

        insides =
            Regex.find Regex.All exp (Debug.log "string" string)
                |> List.map .match
                |> List.map inside
                |> Debug.log "insides"

        outsides =
            Regex.split Regex.All exp string
                |> List.map outside
                |> filterEmptyTextTokens
                |> Debug.log "outsides"
    in
        zip insides outsides


filterEmptyParagraphTokens : List Model -> List Model
filterEmptyParagraphTokens =
    List.filter
        (\x ->
            if x.token == Paragraph then
                if List.length (filterEmptyTextTokens (tokensFromChildren x.children)) == 0 then
                    True
                else
                    True
            else
                True
        )


tokensFromChildren : Children -> List Model
tokensFromChildren (Children tokens) =
    tokens


filterEmptyTextTokens : List Model -> List Model
filterEmptyTextTokens =
    List.filter
        (\x ->
            if x.token == Text then
                if x.value == "" then
                    False
                else
                    True
            else
                True
        )


text : String -> Model
text string =
    Model Text string (Children [])


paragraph : String -> Model
paragraph string =
    Model Paragraph "" (Children (markdownToTokens string))


speech : String -> Model
speech string =
    Model Speech "" (Children [ text (string) ])


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
