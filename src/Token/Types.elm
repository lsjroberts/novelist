module Token.Types exposing (..)


type alias Model =
    { token : TokenType
    , children : Children
    }


type TokenType
    = Paragraph
    | Speech
    | Emphasis
    | Text String


type Children
    = Children (List Model)


type Msg
    = NoOp


openingTag : Model -> Maybe String
openingTag { token } =
    case token of
        Speech ->
            Just "“"

        Emphasis ->
            Just "_"

        _ ->
            Nothing


closingTag : Model -> Maybe String
closingTag { token } =
    case token of
        Speech ->
            Just "”"

        Emphasis ->
            Just "_"

        _ ->
            Nothing


showTags : Model -> Bool
showTags { token } =
    case token of
        Speech ->
            True

        _ ->
            False


value : Model -> Maybe String
value { token } =
    case token of
        Text v ->
            Just v

        _ ->
            Nothing


children : Model -> List Model
children model =
    let
        get (Children cs) =
            cs
    in
        get model.children
