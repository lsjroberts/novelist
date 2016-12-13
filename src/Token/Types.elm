module Token.Types exposing (..)

import Regex


type alias Model =
    { token : TokenType
    , before : Maybe String
    , after : Maybe String
    , inner : Maybe String
    , children : Children
    }


type TokenType
    = Paragraph
    | Speech
    | Emphasis
    | Text


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


filterEmptyTextTokens : List Model -> List Model
filterEmptyTextTokens =
    List.filter
        (\x ->
            if x.token == Text then
                case x.inner of
                    Just inner ->
                        True

                    Nothing ->
                        False
            else
                True
        )


tokensFromChildren : Children -> List Model
tokensFromChildren (Children tokens) =
    tokens


paragraph : String -> Model
paragraph string =
    Model Paragraph Nothing Nothing Nothing (Children (markdownToTokens string))


speech : String -> Model
speech string =
    string
        |> Regex.replace Regex.All (Regex.regex "“|”|\"") (\_ -> "")
        |> markdownToTokens
        |> Children
        |> Model Speech (Just "“") (Just "”") Nothing


emphasis : String -> Model
emphasis string =
    string
        |> Regex.replace Regex.All (Regex.regex "_") (\_ -> "")
        |> markdownToTokens
        |> Children
        |> Model Emphasis Nothing Nothing Nothing


text : String -> Model
text string =
    Model Text Nothing Nothing (Just string) (Children [])


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
