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
        Paragraph ->
            paragraph model

        Speech ->
            speech model

        Emphasis ->
            emphasis model

        Text a ->
            text model


paragraph : Token.Types.Model -> Html Msg
paragraph token =
    inner token.children
        |> p
            [ styles
                [ marginTop (em 0)
                , marginBottom (em 0.5)
                , textIndent (em 1)
                ]
            ]


speech : Token.Types.Model -> Html Msg
speech token =
    token
        |> wrap
        |> span [ styles [ backgroundColor (rgba 0 189 156 0.2) ] ]


emphasis : Token.Types.Model -> Html Msg
emphasis token =
    token
        |> wrap
        |> span [ styles [ fontStyle italic ] ]


wrap : Token.Types.Model -> List (Html Msg)
wrap token =
    let
        before =
            case openingTag token of
                Just b ->
                    if showTags token then
                        [ Html.text b ]
                    else
                        [ span [ styles [ display none ] ] [ Html.text b ] ]

                Nothing ->
                    []

        after =
            case closingTag token of
                Just a ->
                    if showTags token then
                        [ Html.text a ]
                    else
                        [ span [ styles [ display none ] ] [ Html.text a ] ]

                Nothing ->
                    []
    in
        before ++ inner token.children ++ after


inner : Children -> List (Html Msg)
inner (Children children) =
    List.map root children


text : Token.Types.Model -> Html Msg
text token =
    case token.token of
        Text value ->
            Html.text value

        _ ->
            Html.text ""
