module Workspace.View exposing (root)

import Html exposing (Html, div)
import Workspace.Types exposing (..)
import Workspace.Header.View
import Workspace.Styles exposing (class)
import Editor.Types
import Scene.State
import Scene.View


root : Editor.Types.File -> Html Msg
root file =
    div
        [ class [ Workspace.Styles.Root ] ]
        [ Workspace.Header.View.root
        , fileView file
        ]


fileView : Editor.Types.File -> Html Msg
fileView file =
    case file.fileType of
        Editor.Types.Scene ->
            sceneView file

        _ ->
            div [] []


sceneView : Editor.Types.File -> Html Msg
sceneView file =
    let
        scene =
            Scene.State.initNamed file.name
    in
        Scene.View.root scene |> Html.map SceneMsg
