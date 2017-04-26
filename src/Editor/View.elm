module Editor.View exposing (root)

import Html exposing (Html, div, h1)
import Html.Events exposing (onClick)
import Editor.Types exposing (..)
import Editor.Styles exposing (class)
import Menu.View
import Binder.View
import Binder.Types
import Inspector.View
import Panel.View
import Workspace.View


root : Model -> Html Msg
root model =
    div [ class [ Editor.Styles.Root ] ]
        [ Menu.View.root
        , div
            [ class [ Editor.Styles.View ] ]
            [ binderPanel
            , Workspace.View.root |> Html.map WorkspaceMsg
            , inspectorPanel
            ]
        ]


binderPanel : Html msg
binderPanel =
    div
        [ class [ Editor.Styles.Binder ] ]
        [ Panel.View.root
            [ Binder.View.root
                [ (Binder.Types.File "Manuscript" (Binder.Types.FileChildren [ Binder.Types.File "Chapter" (Binder.Types.FileChildren []) ]))
                , (Binder.Types.File "Notes" (Binder.Types.FileChildren []))
                , (Binder.Types.File "Characters" (Binder.Types.FileChildren []))
                , (Binder.Types.File "Locations" (Binder.Types.FileChildren []))
                ]
            ]
        ]


inspectorPanel : Html msg
inspectorPanel =
    div
        [ class [ Editor.Styles.Inspector ] ]
        [ Panel.View.root [ Inspector.View.root ] ]
