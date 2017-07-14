module Data.Token
    exposing
        ( Token
        , TokenChildren(..)
        , TokenType(..)
        , getClosingTag
        , getOpeningTag
        , getShowTags
        , getTokenChildren
        , getTokenValue
        , markdownToTokens
        , tokensToPlainText
        )

import Date exposing (Date)
import Regex


type alias Token =
    { type_ : TokenType
    , children : TokenChildren
    }


type TokenType
    = Paragraph
    | Speech
    | Emphasis
    | CommentTag Int
    | CharacterTag Int
    | LocationTag Int
    | Text String


type TokenChildren
    = TokenChildren (List Token)


getOpeningTag : Token -> Maybe String
getOpeningTag { type_ } =
    case type_ of
        Speech ->
            Just "“"

        Emphasis ->
            Just "_"

        _ ->
            Nothing


getClosingTag : Token -> Maybe String
getClosingTag { type_ } =
    case type_ of
        Speech ->
            Just "”"

        Emphasis ->
            Just "_"

        _ ->
            Nothing


getShowTags : Token -> Bool
getShowTags { type_ } =
    case type_ of
        Speech ->
            True

        Emphasis ->
            True

        _ ->
            False


getOpeningTagMatches : Token -> Maybe (List String)
getOpeningTagMatches { type_ } =
    case type_ of
        Speech ->
            Just [ "“", "\"" ]

        Emphasis ->
            Just [ "_" ]

        _ ->
            Nothing


getClosingTagMatches : Token -> Maybe (List String)
getClosingTagMatches { type_ } =
    case type_ of
        Speech ->
            Just [ "”", "\"" ]

        Emphasis ->
            Just [ "_" ]

        _ ->
            Nothing


getTokenValue : Token -> Maybe String
getTokenValue { type_ } =
    case type_ of
        Text v ->
            Just v

        _ ->
            Nothing


getTokenChildren : Token -> List Token
getTokenChildren token =
    let
        get (TokenChildren cs) =
            cs
    in
        get token.children


markdownToTokens : String -> List Token
markdownToTokens string =
    let
        cleanString =
            Regex.replace Regex.All (Regex.regex "\n+$") (\_ -> "\n") string

        tokens =
            if String.contains "\n" cleanString then
                cleanString
                    |> String.split "\n"
                    |> List.map paragraph
            else if String.contains "“" cleanString then
                tokenWrap2 "“" "”" speech text string
            else if String.contains "\"" cleanString then
                tokenWrap "\"" speech text string
            else if String.contains "_" cleanString then
                tokenWrap "_" emphasis text cleanString
            else
                [ text cleanString ]
    in
        tokens |> filterEmptyParagraphTokens


paragraph : String -> Token
paragraph string =
    string
        |> markdownToTokens
        |> TokenChildren
        |> Token Paragraph


speech : String -> Token
speech string =
    string
        |> Regex.replace Regex.All (Regex.regex "“|”|\"") (\_ -> "")
        |> markdownToTokens
        |> TokenChildren
        |> Token Speech


emphasis : String -> Token
emphasis string =
    string
        |> Regex.replace Regex.All (Regex.regex "_") (\_ -> "")
        |> markdownToTokens
        |> TokenChildren
        |> Token Emphasis


text : String -> Token
text string =
    Token (Text string) (TokenChildren [])


tokenWrap char =
    tokenWrap2 char char


tokenWrap2 : String -> String -> (String -> Token) -> (String -> Token) -> String -> List Token
tokenWrap2 left right inside outside string =
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


filterEmptyParagraphTokens : List Token -> List Token
filterEmptyParagraphTokens =
    List.filter
        (\x ->
            if x.type_ == Paragraph then
                if List.length (filterEmptyTextTokens (getTokenChildren x)) == 0 then
                    False
                else
                    True
            else
                True
        )


filterEmptyTextTokens : List Token -> List Token
filterEmptyTextTokens =
    List.filter
        (\x ->
            case x.type_ of
                Text value ->
                    if String.length value > 0 then
                        True
                    else
                        False

                _ ->
                    False
        )


tokensToPlainText : List Token -> String
tokensToPlainText tokens =
    tokens
        |> List.map tokenToPlainText
        |> List.foldl (++) ""


tokenToPlainText : Token -> String
tokenToPlainText token =
    let
        children =
            getTokenChildren token
    in
        case getTokenValue token of
            Just value ->
                String.trim value

            Nothing ->
                if List.isEmpty children then
                    ""
                else
                    tokensToPlainText children


zip : List a -> List a -> List a
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
