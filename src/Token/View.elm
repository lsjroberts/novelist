module Token.View exposing (root)

import Css exposing (..)
import Html exposing (Html, Attribute, div, span, p)
import Token.Types exposing (..)
import Styles exposing (styles)


type alias HtmlTag =
    List (Attribute Msg) -> List (Html Msg) -> Html Msg


root : Model -> Html Msg
root model =
    case model.token of
        Text ->
            text model.value

        Paragraph ->
            paragraph model.children

        Speech ->
            speech model.children


text : String -> Html Msg
text string =
    Html.text string



-- children : HtmlTag -> Children -> Html Msg
-- children element (Children tokens) =
--     tokens
--         |> List.map root
--         |> element []


paragraph : Children -> Html Msg
paragraph (Children tokens) =
    tokens
        |> List.map root
        |> p
            [ styles
                [ marginTop (em 0)
                , marginBottom (em 0.5)
                , textIndent (em 1)
                ]
            ]


speech : Children -> Html Msg
speech (Children tokens) =
    tokens
        |> List.map root
        |> span [ styles [ backgroundColor (rgba 0 189 156 0.2) ] ]
