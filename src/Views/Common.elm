module Views.Common exposing (viewPanel, viewMenu)

import Html exposing (..)
import Html.Events exposing (..)
import Data.Ui exposing (ViewType(..))
import Messages exposing (Msg(..))
import Styles exposing (class)


viewMenu : ViewType -> Html Msg
viewMenu activeView =
    let
        viewToggle =
            case activeView of
                EditorView ->
                    div [ onClick (SetActiveView SettingsView) ]
                        [ Html.text "Settings" ]

                SettingsView ->
                    div [ onClick (SetActiveView EditorView) ]
                        [ Html.text "Editor" ]
    in
        div
            [ class [ Styles.Menu ] ]
            [ viewToggle ]


viewPanel : List (Html Msg) -> Html Msg
viewPanel children =
    div [ class [ Styles.Panel ] ] children
