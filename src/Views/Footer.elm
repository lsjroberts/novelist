module Views.Footer exposing (view)

import Html exposing (..)
import Html.Attributes exposing (value)
import Html.Events exposing (..)
import Data.Model exposing (..)
import Styles exposing (class)
import Messages exposing (Msg(..))


view : Model -> Html Msg
view model =
    div
        [ class [ Styles.Footer ] ]
        [ viewFooterCommit model
        , viewFooterWordCount model
        ]


viewFooterCommit : Model -> Html Msg
viewFooterCommit model =
    let
        commitCount =
            case getActiveScene model of
                Just scene ->
                    scene.commit

                Nothing ->
                    0

        commit =
            commitCount
                |> toString
                |> Html.text
    in
        div [ class [ Styles.FooterCommit ] ]
            [ commit ]


viewFooterWordCount : Model -> Html Msg
viewFooterWordCount model =
    let
        wordCount =
            model
                |> getActiveSceneWordCount
                |> toString
                |> Html.text
    in
        div [ class [ Styles.FooterWordCount ] ]
            [ wordCount
            , viewFooterWordTarget model
            ]


viewFooterWordTarget : Model -> Html Msg
viewFooterWordTarget model =
    let
        maybeScene =
            getActiveScene model

        wordTarget =
            case maybeScene of
                Just scene ->
                    scene.wordTarget

                Nothing ->
                    0

        wordTargetInput =
            case maybeScene of
                Just scene ->
                    input
                        [ class [ Styles.FooterWordTarget ]
                        , onInput (SetSceneWordTarget scene.id)
                        , value (toString wordTarget)
                        ]
                        []

                Nothing ->
                    span [] []
    in
        if wordTarget > 0 then
            span []
                [ Html.text " of "
                , wordTargetInput
                ]
        else
            span [] []
