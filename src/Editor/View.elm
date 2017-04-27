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
            [ binderPanel model
            , workspace model
            , inspectorPanel
            ]
        ]


binderPanel : Model -> Html Msg
binderPanel model =
    div
        [ class [ Editor.Styles.Binder ] ]
        [ Panel.View.root
            [ Binder.View.root model.files |> Html.map BinderMsg ]
        ]


workspace : Model -> Html Msg
workspace model =
    let
        activeFile =
            case model.active of
                Just activePath ->
                    model.files
                        |> List.filter (\file -> file.id == activePath)
                        |> List.head

                Nothing ->
                    Nothing
    in
        case activeFile of
            Just file ->
                Workspace.View.root file |> Html.map WorkspaceMsg

            Nothing ->
                div [] []


inspectorPanel : Html msg
inspectorPanel =
    div
        [ class [ Editor.Styles.Inspector ] ]
        [ Panel.View.root [ Inspector.View.root ] ]
