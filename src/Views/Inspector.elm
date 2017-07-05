module Views.Inspector exposing (view)

import Date exposing (Date)
import Html exposing (..)
import Maybe.Extra
import Styles exposing (class)
import Messages exposing (Msg(..))
import Utils.Date exposing (..)
import Views.Common exposing (viewPanel)


view : Maybe Date -> Maybe Int -> Int -> Html Msg
view deadline totalWordTarget totalWordCount =
    div
        [ class [ Styles.Inspector ] ]
        [ viewPanel
            [ viewInspectorDeadline deadline
            , viewInspectorWords totalWordTarget totalWordCount
            ]
        ]


viewInspectorDeadline : Maybe Date -> Html Msg
viewInspectorDeadline deadline =
    let
        deadlineString =
            Maybe.Extra.unwrap "" formatDateHuman deadline
    in
        div []
            [ Html.text deadlineString ]


viewInspectorWords : Maybe Int -> Int -> Html Msg
viewInspectorWords totalWordTarget totalWordCount =
    let
        countString =
            toString totalWordCount

        phrase =
            case totalWordTarget of
                Just target ->
                    countString ++ " words of " ++ (toString target) ++ " word target"

                Nothing ->
                    countString ++ " words"

        percent =
            case totalWordTarget of
                Just target ->
                    (toString (floor ((totalWordCount * 100 |> toFloat) / (toFloat target)))) ++ "% complete"

                Nothing ->
                    "no target"
    in
        div []
            [ div [] [ Html.text phrase ]
            , div [] [ Html.text percent ]
            ]
