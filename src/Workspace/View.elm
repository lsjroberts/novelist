module Workspace.View exposing (root)

import Html exposing (Html, div)
import Workspace.Types exposing (..)
import Workspace.Header.View
import Workspace.Styles exposing (class)
import Scene.State
import Scene.View


root : Html Msg
root =
    let
        ( scene, _ ) =
            Scene.State.init
    in
        div
            [ class [ Workspace.Styles.Root ] ]
            [ Workspace.Header.View.root
            , Scene.View.root scene |> Html.map SceneMsg
            ]
