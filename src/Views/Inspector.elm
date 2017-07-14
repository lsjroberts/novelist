module Views.Inspector exposing (view)

import Data.Comment exposing (Comment)
import Date exposing (Date)
import Html exposing (..)
import Maybe.Extra
import Styles exposing (class)
import Messages exposing (Msg(..))
import Octicons as Icon
import Utils.Date exposing (..)
import Views.Common exposing (viewPanel)


view : List Comment -> Html Msg
view comments =
    div
        [ class [ Styles.Inspector ] ]
        [ viewPanel
            [ viewInspectorComments comments
            ]
          -- [ viewInspectorDeadline deadline
          -- , viewInspectorWords totalWordTarget totalWordCount
          -- ]
        ]


viewInspectorComments : List Comment -> Html Msg
viewInspectorComments comments =
    let
        viewComment comment =
            div [ class [ Styles.Comment ] ]
                [ p [] [ Html.text comment.message ]
                , p [ class [ Styles.CommentMeta ] ] [ Html.text comment.author ]
                ]

        viewComments =
            comments |> List.map viewComment
    in
        div [] <|
            [ h2
                [ class [ Styles.PanelTitle ] ]
                [ span [ class [ Styles.PanelTitleIcon ] ]
                    [ Icon.defaultOptions
                        |> Icon.color "white"
                        |> Icon.size 28
                        |> Icon.repo
                    ]
                , Html.text "Comments"
                ]
            ]
                ++ viewComments


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
